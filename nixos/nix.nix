{ pkgs, nixpkgs, username, ... }:

{

  nix = {
    channel.enable = false; # exclude legacy path from NIX_PATH

    package = pkgs.nixVersions.git;
    registry."nixpkgs".flake = nixpkgs;

    gc.automatic = true;

    settings = rec {
      keep-outputs = true;
      keep-derivations = true;
      auto-optimise-store = true;
      use-cgroups = true;
      warn-dirty = false;
      auto-allocate-uids = true;
      experimental-features =
        [ "nix-command" "flakes" "auto-allocate-uids" "cgroups" ];
      extra-experimental-features = [ "ca-derivations" ];
      trusted-users = [ "@wheel" username ];
      allowed-users = trusted-users;
      substituters = [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
      ];
    };
  };
}

