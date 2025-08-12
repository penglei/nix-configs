#!/usr/bin/env bash

function render_kitty_tabs()
{

  # ➀ ➁ ➂ ➃ ➄ ➅ ➆ ➇ ➈ ➉
  # ⓵ ⓶ ⓷ ⓸ ⓹ ⓺ ⓻ ⓼ ⓽ ⑩ ⑪ ⑫ ⑬ ⑭ ⑮ ⑯ ⑰ ⑱ ⑲ ⑳
  # ➊ ➋ ➌ ➍ ➎ ➏ ➐ ➑ ➒ ➓ ⓫ ⓬ ⓭ ⓮ ⓯ ⓰ ⓱ ⓲ ⓳ ⓴

  local ICONS=("" "⓵" "⓶" "⓷" "⓸" "⓹" "⓺" "⓻" "⓼" "⓽" "⑩" "⑪" "⑫" "⑬" "⑭" "⑮" "⑯" "⑰" "⑱" "⑲" "⑳")
  # BlACK_ICONS=("" "➊" "➋" "➌" "➍" "➎" "➏" "➐" "➑" "➒" "➓" "⓫" "⓬" "⓭" "⓮" "⓯" "⓰" "⓱" "⓲" "⓳" "⓴")

  local tab_names=()
  local set_args=(-m)
  local curr_tab_index
  local curr_num_tabs

  curr_num_tabs=$(jq '.curr_num_tabs' < ~/.local/state/kitty/data.json)

  if [ "$curr_num_tabs" -le 0 ]; then
    return
  fi

  curr_tab_index=$(jq '.curr_tab_index' < ~/.local/state/kitty/data.json)
  # for i in {1..$curr_num_tabs}; do
  for i in $(seq 1 "$curr_num_tabs"); do

    local font_size=14
    # if [ $i -le 10 ];then
    #   font_size=24
    # fi

    local icon=${ICONS[i]}

    local tab_name=kitty_tab.$i
    tab_names+=($tab_name)
    set_args+=(--add item $tab_name left --set $tab_name)

    if [ "$i" == 1 ];then
      set_args+=(icon.padding_left=10)
    fi
    if [ $i == $curr_num_tabs ];then
      set_args+=(icon.padding_right=0)
    fi

    if [ $i == "$curr_tab_index" ];then
      font_size=18
      # icon=${ICONS[i]}
      set_args+=("icon.color=0xffb2ebf2")
      # set_args+=(y_offset=-1)
    else
      set_args+=("icon.color=0xffa3c6d4")
      # icon=${BlACK_ICONS[i]}
    fi

    set_args+=(
        icon.font="MonaspiceNe Nerd Font:Bold:$font_size"
        label.font="MonaspiceNe Nerd Font:Bold:14.0"
        icon=${icon}
    )

    # sketchybar "${set_args[@]}"
    # sketchybar --add item kitty_tab.$i left                     \
    #   --set kitty_tab.$i                                        \
    #     icon.font="MonaspiceNe Nerd Font:Bold:$font_size"       \
    #     label.font="MonaspiceNe Nerd Font:Bold:14.0"            \
    #     icon=${icon} "${set_args[@]}"
  done

  sketchybar "${set_args[@]}"

  # sketchybar --add bracket kitty_tabs                           \
  #                 "${tab_names[@]}"                             \
  #            --set kitty_tabs                                   \
  #                 background.color=0xff1f7eb7                   \
  #                 background.corner_radius=2                    \
  #                 background.height=26

}

function clear_kitty_tabs() {
  sketchybar --remove '/kitty_tab.[0-9]*/' || true
}


# TODO: diff to update instead of re-rendering all
# sketchybar --query bar | jq -r '.items[]'

clear_kitty_tabs
render_kitty_tabs
