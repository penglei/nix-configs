#!/usr/bin/env bash

## 垂直方向不能在tiling和floating之间切换 ##

function select_window() {
  local direction="$1"
  local from_id="$2"
  local cmp_op="<"

  if [ "$direction" = "south" ]; then
    cmp_op=">"
  fi

  local all_windows
  all_windows="$(yabai -m query --windows --space)"

  jq -r "first(.[] | select(.[\"is-floating\"] == true and .id $cmp_op $from_id) | .id)" <<<"$all_windows"
}

function focus() {
  local direction="$1"

  if ! yabai -m window --focus "$direction"; then
    focused_window="$(yabai -m query --windows --window)"
    if [ "$(jq '."is-floating"' <<<"$focused_window")" = "true" ]; then
      window_id=$(select_window "$direction" "$(jq ".id" <<<"$focused_window")")
      if [ -n "$window_id" ]; then
        yabai -m window --focus "$window_id"
      fi
    else
      yabai -m window --focus "$direction"
    fi
  fi
}

focus "$1"
