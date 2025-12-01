{
  config,
  lib,
  pkgs,
  ...
}:

let
  apps = pkgs.buildEnv {
    name = "home-manager-applications";
    paths = config.home.packages;
  };
in
{

  #Not so good: after updating pkgs.tart, you need to refresh the shell to use it.
  # home.sessionPath = [ "${pkgs.tart}/Applications/tart.app/Contents/MacOS" ];

  # Home-manager does not link installed applications to the user environment. This means apps will not show up
  # in spotlight, and when launched through the dock they come with a terminal window. This is a workaround.
  # Upstream issue: https://github.com/nix-community/home-manager/issues/1341
  home.activation.CreateUserApplicationAlias = lib.hm.dag.entryAfter [ "writeBoundary" ] ''

    echo "[Darwin]---------------------------------------------"
    ls ${apps}/Applications
    echo "[Darwin]---------------------------------------------"
    echo "[Darwin] Make application alias to ~/Applications" >&2

    appliation_alias_dir="$HOME/Applications"

    find $appliation_alias_dir -maxdepth 1 -type f -name '*.app' -delete

    $DRY_RUN_CMD  find ${apps}/Applications -type l -exec readlink -f '{}' + |
        while read app; do

            app_name="$(basename "$app")"
            if [[ -e "$appliation_alias_dir/$app_name" ]]; then
              rm -rf "$appliation_alias_dir/$app_name"
            fi

            # Spotlight does not recognize symlinks, it will ignore directory linked to the applications folder.
            # Luckily, it understand MacOS aliases, a unique filesystem feature. But the aliase cannot be created
            # from bash (as far as I know), so we use the oh-so-great Apple Script instead.
            /usr/bin/osascript -e "
                set fileToAlias to POSIX file \"$app\" 
                set applicationsFolder to POSIX file \"$appliation_alias_dir\"

                tell application \"Finder\"
                    make alias file to fileToAlias at applicationsFolder
                    set name of result to \"$app_name\"
                end tell
            " 1>/dev/null
        done

    # Delete the directory link
    echo removing the link file 'Applications/Home Manager Apps'

    if [ -d $HOME/Applications/Home\ Manager\ Apps ]; then
      $DRY_RUN_CMD rm $HOME/Applications/Home\ Manager\ Apps
    fi
  '';
}
