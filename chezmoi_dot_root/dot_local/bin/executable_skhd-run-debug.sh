#!/usr/bin/env bash

function select_a_tiling_window() {
  local floating="$1"
  local all_windows
  all_windows="$(yabai -m query --windows --space)"
  jq -r "first(.[] | select(.[\"is-floating\"] == $floating) | .id)" <<<"$all_windows"
}

#for west
# if ! yabai -m window --focus west; then
#   focused_window="$(yabai -m query --windows --window)"
#   if [ "$(jq '."is-floating"' <<<"$focused_window")" = "true" ]; then
#     window_id=$(select_a_tiling_window "false")
#     if [ -n "$window_id" ]; then
#       yabai -m window --focus "$window_id"
#     fi
#   else
#     yabai -m window --focus west
#   fi
# fi

#for east
if ! yabai -m window --focus east; then
  focused_window="$(yabai -m query --windows --window)"
  if [ "$(jq '."is-floating"' <<<"$focused_window")" = "false" ]; then
    window_id=$(select_a_tiling_window "true")
    if [ -n "$window_id" ]; then
      yabai -m window --focus "$window_id"
    fi
  else
    yabai -m window --focus west
  fi
fi
