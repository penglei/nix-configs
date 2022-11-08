{ writeShellApplication }:

writeShellApplication {
  name = "nix-cleaner";
  text = ''
    if type home-manager > /dev/null 2>&1; then
      home-manager expire-generations "$(home-manager generations|head -n 1 | awk -F ' : ' '{print $1}')"
    fi

    nix profile wipe-history

    if [[ -L /nix/var/nix/profiles/per-user/''${USER}/home-manager ]]; then
      nix profile wipe-history --profile "/nix/var/nix/profiles/per-user/''${USER}/home-manager"
    fi

    #nix-env --delete-generations old
    if [[ -L /nix/var/nix/profiles/default ]]; then
      echo nix profile wipe-history --profile /nix/var/nix/profiles/default 
    fi

    if [[ -L /nix/var/nix/profiles/system ]]; then
      echo nix profile wipe-history --profile /nix/var/nix/profiles/system
      #sudo nix-env -p /nix/var/nix/profiles/system --delete-generations old
    fi

    if [[ -L /nix/var/nix/profiles/per-user/root/profile ]]; then
      echo nix profile wipe-history --profile /nix/var/nix/profiles/per-user/root/profile
    fi
  '';
}
