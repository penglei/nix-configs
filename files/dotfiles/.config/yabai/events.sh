#!/usr/bin/env bash

event="$1"

case "$event" in
window_focused)
  sketchybar -m --trigger window_focus &>/dev/null
  ;;
window_title_changed)
  sketchybar -m --trigger title_change &>/dev/null
  ;;
space_changed)
  sketchybar -m --trigger space_change &>/dev/null
  ;;
window_resized)
  sketchybar -m --trigger window_resize &>/dev/null
  ;;
window_destroyed)
  "$HOME"/.config/yabai/focus_space_window.sh
  echo "window destroyed"
  ;;
*)
  echo "ignore event: $event"
  ;;

esac
