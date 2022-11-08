#!/usr/bin/env zsh

apps_dir="$HOME/Applications/Home Manager Apps"

rm -rf "$HOME/Applications/Home Manager Apps.backup"

function make_app_alias() {
  local app=$1
  local app_name=$(basename "$app")

  osascript <<EOF
    tell application "Finder" 
    make new alias file at POSIX file "$apps_dir" to POSIX file "$app"
    set name of result to "${app_name}"
    end tell
EOF

}

if [[ -L "$apps_dir" && -d "$apps_dir" ]]; then

  typeset -a apps
  for app in $(cd $apps_dir; find . -type l -exec readlink -f {} \;);
  do
    apps+=($app)
  done

  rm $apps_dir
  mkdir -p $apps_dir

  for app in ${apps[@]}; do
    make_app_alias $app
  done
  
fi


#osascript \                
#  -e 'tell application "Finder"' \
#  -e 'make new alias file at POSIX file "$HOME/Applications/Home Manager Apps" to POSIX file "/nix/store/76az0w1nvsvr57ngy6pjdy3gxxpn8wl1-alacritty-0.11.0/Applications/Alacritty.app"' \
#  -e 'set name of result to "Alacritty.app"' \
#  -e 'end tell'
