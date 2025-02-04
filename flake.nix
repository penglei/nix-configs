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
  };

  outputs = { # nil-language-server,
    self, nixpkgs, nixospkgs, flake-utils, home-manager, sops-nix, microvm, ...
    }:
    let
      inherit (nixpkgs) lib;

      systems =
        [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];
      eachSystem = f: (flake-utils.lib.eachSystem systems f);

    in eachSystem (system:
      let
        overlays = [ (import ./pkgs/all.nix) ];
        pkgs = nixpkgs.legacyPackages.${system}.appendOverlays overlays;
        #pkgs = import nixpkgs { inherit system; overlays = overlays; }; 

      in {

        #for debugging(N.B. track files in git before building):
        #❯ nix build .#nixpkgs.passage
        packages.nixpkgs = pkgs;

        overlays.default = lib.lists.foldr (a: i: a // i) { } overlays;

        # home-manager bootstrap tips:
        #❯ nix shell nixpkgs#git; nix develop; home-manager switch --flake .#penglei
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

        packages.homeConfigurations = let
          profiles = import ./profiles.nix {
            inherit pkgs system home-manager sops-nix;
          };
        in profiles.hm-creator [ "penglei" "ubuntu" ];

        ## nixos
        packages.nixosConfigurations = import ./machines.nix {
          inherit self system overlays microvm;
          nixpkgs = nixospkgs;
          profiles = import ./profiles.nix {
            inherit system home-manager sops-nix;
            pkgs = nixospkgs.legacyPackages.${system}.appendOverlays overlays;
          };
        };
      }); # each system
}
