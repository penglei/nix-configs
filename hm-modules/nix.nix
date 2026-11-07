# this nix hm module is only imported by standalone home-manager scenario, which is define in flake.nix

{ pkgs, nixpkgs, config, lib, ... }: {

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
      allow-import-from-derivation = true;
    };
  };

  # Home Manager (including upstream master) installs the user profile with
  # `nix profile install`. Nix >= 2.34 deprecated that name in favour of
  # `nix profile add`, so every activation prints
  #   warning: 'install' is a deprecated alias for 'add'
  # Upstream keeps `install` for compatibility with older Nix, where `add`
  # does not exist. Override the generated activation to use `add` when the
  # active nix supports it, and fall back to `install` on older Nix (which
  # does not emit the warning anyway). Revert once upstream switches to `add`.
  home.activation.installPackages = lib.mkForce (
    lib.hm.dag.entryAfter [ "writeBoundary" ] (
      if config.submoduleSupport.externalPackageInstall then ''
        nixProfileRemove home-manager-path
      '' else ''
        function nixReplaceProfile() {
          local oldNix="$(command -v nix)"

          nixProfileRemove 'home-manager-path'

          run $oldNix profile $PROFILE_ADD_CMD $1
        }

        if [[ -e ${config.home.profileDirectory}/manifest.json ]] ; then
          if nix profile --help 2>&1 | grep -q 'nix profile add' ; then
            PROFILE_ADD_CMD=add
          else
            PROFILE_ADD_CMD=install
          fi
          INSTALL_CMD="nix profile $PROFILE_ADD_CMD"
          INSTALL_CMD_ACTUAL="nixReplaceProfile"
          LIST_CMD="nix profile list"
          REMOVE_CMD_SYNTAX='nix profile remove {number | store path}'
        else
          INSTALL_CMD="nix-env -i"
          INSTALL_CMD_ACTUAL="run nix-env -i"
          LIST_CMD="nix-env -q"
          REMOVE_CMD_SYNTAX='nix-env -e {package name}'
        fi

        if ! $INSTALL_CMD_ACTUAL ${config.home.path} ; then
          echo
          _iError $'Oops, Nix failed to install your new Home Manager profile!\n\nPerhaps there is a conflict with a package that was installed using\n"%s"? Try running\n\n    %s\n\nand if there is a conflicting package you can remove it with\n\n    %s\n\nThen try activating your Home Manager configuration again.' "$INSTALL_CMD" "$LIST_CMD" "$REMOVE_CMD_SYNTAX"
          exit 1
        fi
        unset -f nixReplaceProfile
        unset INSTALL_CMD INSTALL_CMD_ACTUAL LIST_CMD REMOVE_CMD_SYNTAX PROFILE_ADD_CMD
      ''
    )
  );

  ##re-configure nixpkgs (hm will do `import pkgs.path nixpkgs.config` again in internal).
  #we don't do it here anymore, because it has been configured before importing hm modules.
  #nixpkgs.config = {
  #  allowUnfree = true;
  #  allowBroken = true;
  #};
}
