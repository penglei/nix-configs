#!/usr/bin/env sh

has_fullscreen_zoom=$(yabai -m query --windows --window | jq -r '."has-fullscreen-zoom"')

# echo has_fullscreen_zoom:$has_fullscreen_zoom >> $HOME/debug

label=""
case "$has_fullscreen_zoom" in
true)
  label=""
  ;;
false)
  label="﩯" #
  ;;
esac
sketchybar -m --set window_mode label="$label"
#is_floating is-stickey is-topmost has-fullscreen-zoom

#https://github.com/FelixKratz/SketchyBar/discussions/12#discussioncomment-1633997
