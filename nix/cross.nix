{ flake-utils, nixpkgs }:
let
  systems = [
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-linux"
  ];
  eachSystem = flake-utils.lib.eachSystem systems;
in

eachSystem (
  system:
  let
    # pkgs = nixpkgs.legacyPackages.${system};
    makeHostPkg =
      hostSystem:
      (import nixpkgs) {
        inherit system;
        # buildPlatform = { inherit system; };
        # hostPlatform.system = hostSystem;
        crossSystem.config = hostSystem;
      };
    crossPlatformPkgs = builtins.listToAttrs (
      builtins.map (hostSystem: {
        name = hostSystem;
        value = makeHostPkg hostSystem;
      }) (builtins.filter (s: s != system && s != "aarch64-darwin") systems)
    );
  in
  {
    devShells = {
      # default = pkgs.mkShell { };
    }
    // (builtins.mapAttrs (hostPlatform: pkgs: pkgs.mkShell { }) crossPlatformPkgs);
  }
)
