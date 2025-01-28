#!/usr/bin/env bash

window="$(yabai -m query --windows --window)"

window_state="unknown"
if [ -n "$window" ]; then
  if [ "$(jq -r '."is-floating"' <<<"$window")" = "true" ]; then
    window_state="floating"
  else
    if [ "$(jq -r '."has-fullscreen-zoom"' <<<"$window")" = "true" ]; then
      window_state="fullscreen"
    else
      window_state="windowed"
    fi
  fi
fi

label=""
case "$window_state" in
"fullscreen")
  label=""
  ;;
"windowed")
  label=""
  ;;
"unknown")
  label=""
  ;;
"floating")
  label=""
  ;;
esac
sketchybar -m --set window_mode label="$label"

#is_floating is-stickey is-topmost has-fullscreen-zoom

#https://github.com/FelixKratz/SketchyBar/discussions/12#discussioncomment-1633997
