{ lib, config, ... }: {

  home.activation.WriteChezmoiXDGConfig =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      chezmoi_cfg_dir="${config.xdg.configHome}/chezmoi"
      mkdir -p $chezmoi_cfg_dir
      cat <<EOF > $chezmoi_cfg_dir/chezmoi.json
      {
          "sourceDir": "${config.home.homeDirectory}/nix-configs",
          "git": {
              "autoPush": false
          }
      }
      EOF
    '';
}
