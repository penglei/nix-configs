{
  description = "penglei's system configuration powered by Nix";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixospkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixospkgs";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixospkgs";

  };

  outputs = { self, nixpkgs, nixospkgs, flake-utils, home-manager, sops-nix
    , microvm, deploy-rs, ... }:
    let
      inherit (nixpkgs) lib;

      eachSystem = flake-utils.lib.eachSystem [
        "aarch64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];

      profiles = import ./profiles.nix { inherit sops-nix; };
      overlays = [ (import ./pkgs/all.nix) ];

      systems-outputs = eachSystem (system:
        let
          # overlays = [ (import ./pkgs/all.nix) ];
          pkgs = nixpkgs.legacyPackages.${system}.appendOverlays overlays;
          #pkgs = import nixpkgs { inherit system; overlays = overlays; }; 

        in {

          #for debugging(N.B. track files in git before building):
          #❯ nix build .#pkgs.passage
          #packages.pkgs = pkgs;

          #home-manager bootstrap tips:
          #❯ nix shell nixpkgs#git
          #❯ nix develop
          #❯ home-manager switch --flake .
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              home-manager.defaultPackage.${system} # home-manager command
              ssh-to-pgp
              ssh-to-age
            ];
            shellHook = ''
              export PATH=$(pwd)/result/bin:$PATH
            '';
          };
        }); # end each system

      deploy-outputs = let
        system = "x86_64-linux"; # TODO support all platforms
        pkgs = import nixospkgs { inherit system; };
        deployPkgs = import nixospkgs {
          inherit system;
          overlays = [
            deploy-rs.overlays.default
            (self: super: {
              deploy-rs = {
                deploy-rs = pkgs.deploy-rs;
                lib = super.deploy-rs.lib;
              };
            })
          ];
        };
      in {
        #nix run github:serokell/deploy-rs -- .#ganger
        deploy = {
          # sshUser = "penglei";
          magicRollback = false;
          nodes."ganger" = {
            hostname = "192.168.1.5";
            profiles.system = {
              user = "root";
              path = deployPkgs.deploy-rs.lib.activate.nixos
                self.nixosConfigurations."ganger";
            };
          };
        };
        # This is highly advised, and will prevent many possible mistakes
        checks =
          builtins.mapAttrs (_: deployLib: deployLib.deployChecks self.deploy)
          deploy-rs.lib;
      };

      overlay-outputs = {
        overlays.default =
          lib.lists.foldr (f: acc: (final: prev: acc // (f final prev))) { }
          overlays;
      };

    in overlay-outputs // systems-outputs // deploy-outputs // {
      ##home-manager
      #
      # three scenarios:
      #   1. macOS only -- has launchd service
      #   2. some others Linux distribution
      #   3. as a nixos module
      # 
      homeConfigurations = let
        targets = [
          "penglei.aarch64-darwin"
          "penglei.x86_64-linux"
          "ubuntu.x86_64-linux"
          "ubuntu.aarch64-linux"
        ];

        parse = s:
          let info = nixpkgs.lib.strings.splitString "." s;
          in {
            username = builtins.elemAt info 0;
            system = builtins.elemAt info 1;
          };

        hm-creator = { username, system }:
          let
            pkgs = import nixpkgs { inherit system overlays; };
            isDarwin = nixpkgs.lib.hasSuffix "darwin" system;
          in home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [{ home.username = username; }] ++ (if isDarwin then
              profiles.hm.darwin.modules ++ [{
                # Home Manager needs a bit information about you and the paths it should manage.
                home.homeDirectory = "/Users/${username}";
              }]
            else
              profiles.hm.linux.modules
              ++ [{ home.homeDirectory = "/home/${username}"; }]);
          };

        hms = nixpkgs.lib.listToAttrs (map (target: {
          name = target;
          value = hm-creator (parse target);
        }) targets);

      in hms;

      ##nixos
      nixosConfigurations = let
        nixpkgs = nixospkgs;

        nixos-creator =
          { hostname, system, username, modules, hm-modules, ... }:
          nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = { inherit nixpkgs username hostname; };
            modules = [
              home-manager.nixosModules.home-manager
              sops-nix.nixosModules.sops
              { nixpkgs.overlays = overlays; }
              {
                # home-manager.extraSpecialArgs = { inherit username; };
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.${username}.imports = hm-modules;
              }
            ] ++ modules;
          };

        machines = builtins.mapAttrs (name: options:
          let
            config = (options // (lib.optionalAttrs (!(options ? hostname)) {
              hostname = name;
            }) // (lib.optionalAttrs (!(options ? system)) {
              system = "x86_64-linux";
            })) // (lib.optionalAttrs (!(options ? hm-modules)) {
              hm-modules = profiles.hm.linux.modules;
            });
          in nixos-creator config)
          (import ./machines.nix { inherit profiles microvm; });
      in machines;
    };
}
