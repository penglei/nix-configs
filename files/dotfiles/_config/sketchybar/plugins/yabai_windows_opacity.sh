#!/usr/bin/env sh

opacity=$(yabai -m query --windows | jq -r 'if any(.[]; .opacity < 1) then "on" else "off" end')

if [ "$opacity" = "on" ]; then
  sketchybar -m --set window_opacity label=""
else
  sketchybar -m --set window_opacity label=""
fi
