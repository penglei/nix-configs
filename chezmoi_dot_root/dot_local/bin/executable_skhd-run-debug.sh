#!/usr/bin/env bash

#query focus window

log() {
  date +'%Y-%m-%d %H:%M:%S'
  echo "$@"
}
yabai -m query --windows --window

log >&2
yabai -m space --focus 2

all_windows=""
log "-------query all windows---------"
all_windows=$(yabai -m query --windows --space 2)
log "-------query focused window---------"
focused_window=""
focused_window=$(yabai -m query --windows --window)
echo "----------end-----------"

#if focuesed window is empty but there exists some window,
#we must focus a window

echo "11111111:$focused_window"
if [[ -z "$focused_window" && -n "$all_windows" ]]; then
  echo "22222222"
  if [[ $(jq length <<<"$all_windows") != "0" ]]; then
    window=$(jq '.[0]' <<<"$all_windows")
    id=$(jq '.id' <<<"$window")
    echo "must focus a window:$id"
    if [[ -n "$id" ]]; then
      echo "focusing window: $id, app:$(jq '.app' <<<"$window")"
      yabai -m window --focus "$id"
    fi
  fi
fi
