#!/usr/bin/env bash

function focus_space_window() {
  sleep 0.05
  local all_windows=""
  all_windows=$(yabai -m query --windows --space)

  sleep 0.1
  focused_window=""
  focused_window=$(yabai -m query --windows --window) #it will log in stderr 'could not retrieve window details'.

  local window
  local id
  if [[ -z "$focused_window" && -n "$all_windows" ]]; then
    if [[ $(jq length <<<"$all_windows") != "0" ]]; then
      window=$(jq '.[0]' <<<"$all_windows")
      id=$(jq '.id' <<<"$window")
      #echo "must focus a window:$id"
      if [[ -n "$id" ]]; then
        #echo "focusing window: $id, app:$(jq '.app' <<<"$window")"
        yabai -m window --focus "$id"
      fi
    fi
  fi
}

focus_space_window
