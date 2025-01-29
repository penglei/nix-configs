{ yabai, ... }:

''
  #!/usr/bin/env sh

  # the scripting-addition must be loaded manually if
  # you are running yabai on macOS Big Sur. Uncomment
  # the following line to have the injection performed
  # when the config is executed during startup.
  #
  # for this to work you must configure sudo such that
  # it will be able to run the command without password
  #
  # see this wiki page for information:
  #  - https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)
  sudo ${yabai} --load-sa
  yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"

  #需要先手动创建足够的namespace(多次执行 yabai -m space --create)

  ${yabai} -m space 1 --label work      #work
  ${yabai} -m space 2 --label term      #alacritty
  ${yabai} -m space 3 --label editor    #jetbrains, vscode,...
  ${yabai} -m space 4 --label misc
  ${yabai} -m space 6 --label viewer    #skim, koodo, second terminal,...
  ${yabai} -m space 5 --label task      #AFFiNE, logseq,...
  ${yabai} -m space 7 --label web       #chrome,safari
  ${yabai} -m space 8 --label social    #telegram,wechat,...
  ${yabai} -m space 9 --label relax     #QQ音乐,...
  ${yabai} -m space 10 --label adhoc

  # apps unmanaged (float window)
  if [ -f $HOME/.config/yabai/unmanaged-apps.txt ];then
    ${yabai} -m rule --add app="^($(cat $HOME/.config/yabai/unmanaged-apps.txt | grep '^[^#]' | head -c-1 - | tr '\n' '|'))$" manage=off
  fi

  #${yabai} -m rule --add app="^mpv$" manage=off sticky=on opacity=1.0 grid=8:8:6:0:2:2
  ${yabai} -m rule --add app="^TencentMeeting$" space=work
  ${yabai} -m rule --add app="^WeCom$" space=work
  ${yabai} -m rule --add app="^AFFiNE|Logseq|Notes$" space=task
  ${yabai} -m rule --add app="^(Skim|Koodo Reader|EuDic)$" space=viewer
  ${yabai} -m rule --add app="^(Google Chrome|Safari|Firefox)" space=web
  ${yabai} -m rule --add app="^(Telegram|WeChat)$" space=social
  ${yabai} -m rule --add app="^(QQ音乐|迅雷)$" space=relax
  ${yabai} -m rule --add app="^(iOA)$" space=adhoc

  ${yabai} -m config focus_follows_mouse off #autoraise, off

  ${yabai} -m config \
  	mouse_follows_focus on \
  	window_placement second_child \
  	window_shadow off \
  	window_animation_duration 0.0 \
  	window_opacity_duration 0.0 \
  	active_window_opacity 1.0 \
  	normal_window_opacity 0.97 \
  	window_opacity on \
  	insert_feedback_color 0xaad75f5f \
  	split_ratio 0.50 \
  	split_type auto \
  	auto_balance off \
  	top_padding 02 \
  	left_padding 02 \
  	right_padding 02 \
  	bottom_padding 02 \
  	window_gap 06 \
  	layout bsp \
  	mouse_modifier fn \
  	mouse_action1 move \
  	mouse_action2 resize \
  	mouse_drop_action swap

  #	mouse_follows_focus on \
  #	window_placement first_child \
  #	window_topmost off \
  #	window_shadow off \
  #	window_animation_duration 0.0 \
  #	window_opacity_duration 0.0 \
  #	active_window_opacity 1.0 \
  #	normal_window_opacity 0.97 \
  #	window_opacity on \
  #	insert_feedback_color 0xaad75f5f \
  #	active_window_border_color 0xBF775759 \
  #	normal_window_border_color 0x7f353535 \
  #	window_border_width 2 \
  #	window_border_radius 12 \
  #	window_border_blur on \
  #	window_border_hidpi on \
  #	window_border off \
  #	split_ratio 0.50 \
  #	split_type auto \
  #	auto_balance off \
  #	top_padding 02 \
  #	left_padding 02 \
  #	right_padding 02 \
  #	bottom_padding 02 \
  #	window_gap 06 \
  #	layout bsp \
  #	mouse_modifier fn \
  #	mouse_action1 move \
  #	mouse_action2 resize \
  #	mouse_drop_action swap

  # S K E T C H Y B A R  E V E N T S
  #we don't query by sketchybar command, which needs yabai start after sketchybar when bootstraping.
  #${yabai} -m config external_bar all:0:$(sketchybar --query bar | jq -r '.height')
  ${yabai} -m config external_bar all:0:32

  #listener can query window and space by:
  #❯ yabai -m query --windows --window
  #❯ yabai -m query --spaces --space
  ${yabai} -m signal --add event=window_focused action="$HOME/.config/yabai/event.sh window_focused"
  ${yabai} -m signal --add event=window_title_changed action="$HOME/.config/yabai/event.sh window_title_changed"
  ${yabai} -m signal --add event=space_changed action="$HOME/.config/yabai/event.sh space_changed"
  ${yabai} -m signal --add event=window_resized action="$HOME/.config/yabai/event.sh window_resized"
  ${yabai} -m signal --add event=window_destroyed action="$HOME/.config/yabai/event.sh window_destroyed"

  echo "yabai configuration loaded.."
''
