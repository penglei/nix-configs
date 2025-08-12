#!/usr/bin/env sh

# sleep 0.3

PLUGIN_DIR="$HOME/.config/sketchybar/plugins"

app_name="$(yabai -m query --windows --window | jq -r '.app')"

# window_title=$(yabai -m query --windows --window | jq -r '.title')
# if [ -n "$window_title" ];then
#   window_title=":$window_title"
# fi
# window_title_value="$app_name$window_title"

window_title_value="$app_name"
if [ ${#window_title_value} -gt 210 ]; then
  window_title_value=$(echo -n "$window_title_value" | cut -c 1-210)
  sketchybar --set window_title label="${window_title_value}…"
else
  sketchybar --set window_title label="$window_title_value"
fi

if [ "$app_name" == "kitty" ];then
  $PLUGIN_DIR/kitty_tabs.sh
else
  sketchybar --remove '/kitty_tab.[0-9]*/' || true
fi
