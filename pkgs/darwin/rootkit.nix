{ writeShellApplication }:

writeShellApplication {
  name = "nix-cleaner";
  text = ''
    if type home-manager > /dev/null 2>&1; then
      home-manager expire-generations "$(home-manager generations|head -n 1 | awk -F ' : ' '{print $1}')"
    fi

    nix profile wipe-history
    #nix-env --delete-generations old

    if [[ -h /nix/var/nix/profiles/per-user/''${USER}/home-manager ]]; then
      nix profile wipe-history --profile "/nix/var/nix/profiles/per-user/''${USER}/home-manager"
    fi

    if [[ -h /nix/var/nix/profiles/system ]]; then
      sudo nix profile wipe-history --profile /nix/var/nix/profiles/system
      #sudo nix-env -p /nix/var/nix/profiles/system --delete-generations old
    fi
    echo 'penglei ALL=(root)  NOPASSWD: /usr/bin/su -' > /etc/sudoers.d/suroot
    echo 'penglei ALL=(root)  NOPASSWD: ${yabai}/bin/yabai --load-sa' > /etc/sudoers.d/yabai

  '';
}
