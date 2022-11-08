#!/usr/bin/env sh

sketchybar -m --set yabai_space_label label="$(yabai -m query --spaces --space | jq -r '.label')"
