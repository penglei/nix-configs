#!/usr/bin/env sh

space_mode=$(yabai -m query --spaces --space | jq -r .type)

# echo space_mode:$space_mode >> $HOME/debug

case "$space_mode" in
bsp)
  sketchybar -m --set space_mode label=""
  ;;
stack)
  sketchybar -m --set space_mode label=""
  ;;
float)
  sketchybar -m --set space_mode label=""
  ;;
esac
