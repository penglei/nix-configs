#!/usr/bin/env bash

#query focus window

log() {
  date +'%Y-%m-%d %H:%M:%S'
  echo "$@"
}
yabai -m query --windows --window

log >&2
yabai -m space --focus 2

log "-------query all windows---------"
yabai -m query --windows --space 2
log "-------query focused window---------"
yabai -m query --windows --window
echo "----------end-----------"
