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

    # System/root profiles are owned by root and use the legacy nix-env
    # format, which `nix profile wipe-history` cannot handle.
    if command -v sudo > /dev/null 2>&1; then
      for profile in \
        /nix/var/nix/profiles/system \
        /nix/var/nix/profiles/default \
        /nix/var/nix/profiles/per-user/root/profile
      do
        if [[ -L "$profile" ]]; then
          sudo nix-env -p "$profile" --delete-generations old
        fi
      done

      sudo nix-collect-garbage

      # /boot keeps the kernels of deleted generations until the bootloader
      # entries are regenerated. Use the current system's script so this also
      # works on flake-based hosts without knowing the flake ref.
      if [[ -e /etc/NIXOS ]] && [[ -x /run/current-system/bin/switch-to-configuration ]]; then
        sudo /run/current-system/bin/switch-to-configuration boot
      fi
    fi
  '';
}
