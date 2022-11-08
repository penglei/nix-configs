# this nix hm module is only imported by standalone home-manager scenario, which is define in flake.nix

{ pkgs, nixpkgs, ... }: {

  nix = {
    package = pkgs.nixVersions.git;
    registry."nixpkgs".flake = nixpkgs;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      keep-outputs = true;
      keep-derivations = true;
      substituters = [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
      ];
    };
  };

  ##re-configure nixpkgs (hm will do `import pkgs.path nixpkgs.config` again in internal).
  #we don't do it here anymore, because it has been configured before importing hm modules.
  #nixpkgs.config = {
  #  allowUnfree = true;
  #  allowBroken = true;
  #};
}
