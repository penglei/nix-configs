#!/usr/bin/env bash

function focus() {
  local direction="$1"

  if ! yabai -m window --focus "$direction"; then
    #Unable to move any further, it indicates that the edge has been reached.
    focused_window="$(yabai -m query --windows --window)"
    if [ "$(jq '."is-floating"' <<<"$focused_window")" = "false" ]; then
      #Currently, our focus is on a tiling window, and we are to transition to the floating windows layer.

      echo "to floating windows layer"
      #Which floating window should be selected in the horizontal/vertical direction?
      #All windows can be sorted by the x-axis/y-axis, and then the starting window at
      #either end (horizontal/vertical) can be chosen based on the direction of movement.
    else
      #Currently, our focus is on a floating window, and we are to select the next floating window.
      #The question arises: which floating window should be chosen next?
      #We employ the same x-axis/y-axis sorting method to select the subsequent window.

      #If we are already at the edge of the floating window,
      #we then shift to the tiling windows layer and focus on the tiling window that
      #is nearest to the edge of the floating window.
      echo "to tiling windows layer"
    fi
  fi
}

focus "$1"
