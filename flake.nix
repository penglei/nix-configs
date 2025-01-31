{
  description = "penglei's system configuration powered by Nix";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgsForNixOS.url = "github:nixos/nixpkgs/nixos-unstable";

    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgsForNixOS";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nil-language-server = {
      url = "github:oxalica/nil";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = { self, nixpkgs, nixpkgsForNixOS, flake-utils, home-manager
    , sops-nix, nil-language-server, microvm, ... }:
    let
      inherit (nixpkgs) lib;

      systems =
        [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];
      eachSystem = f: (flake-utils.lib.eachSystem systems f);

    in eachSystem (system:
      let
        pkgOverlays = [
          (import ./pkgs/all.nix)
          (final: prev: {
            nil-language-server = nil-language-server.packages.${system}.nil;
          })
        ];
        pkgs = nixpkgs.legacyPackages.${system}.appendOverlays pkgOverlays;
        #pkgs = import nixpkgs { inherit system; overlays = pkgOverlays; }; 

        profiles =
          import ./profiles.nix { inherit pkgs system home-manager sops-nix; };
      in {

        #for debugging(do git track before building):
        #❯ nix build .#nixpkgs.passage
        packages.nixpkgs = pkgs;

        overlays.default = lib.lists.foldr (a: i: a // i) { } pkgOverlays;

        # home-manager bootstrap: `nix shell nixpkgs#git; nix develop; home-manager switch --flake .#penglei`
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

        ##*home-manager* is used in 3 scenarios:
        ##  1. macOS only -- has launchd service
        ##  2. some others Linux distribution
        ##  3. as a nixos module
        ##
        ##config:
        ##  1,2: #packages.${system}.homeConfigurations = self.homeConfigurations;
        ##    3: {home-manager.users.${username}.imports = hm-modules}

        packages.homeConfigurations = profiles.hm-creator.standalone "penglei"
          // profiles.hm-creator.standalone "ubuntu";

        ## nixos linux only
        packages.nixosConfigurations = import ./machines.nix {
          inherit self system pkgOverlays microvm;
          nixpkgs = nixpkgsForNixOS;
          profiles = import ./profiles.nix {
            inherit system home-manager sops-nix;
            pkgs = nixpkgsForNixOS.legacyPackages.${system}.appendOverlays
              pkgOverlays;
          };
        };
      }); # each system
}
