{ pkgs, config, ... }:

#key docs: https://github.com/koekeishiya/skhd/issues/1

let
  yabai = "${pkgs.yabai}/bin/yabai";
  skhd = "${pkgs.skhd}/bin/skhd";
  alacritty = "${pkgs.alacritty}/bin/alacritty";
  sketchybar = "${pkgs.sketchybar}/bin/sketchybar";
  jq = "${pkgs.jq}/bin/jq";
in {
  # https://ss64.com/osx/launchctl.html
  launchd.agents.skhd = {
    enable = true;

    config = {
      ProgramArguments = [ skhd ];
      EnvironmentVariables = {
        "PATH" = config.launch_agent_common.path_env;
        "SHELL" = "/bin/sh";
      };
      KeepAlive = true;
      RunAtLoad = true;
      ProcessType = "Interactive";
      StandardErrorPath = "/tmp/skhd.err.log";
      StandardOutPath = "/tmp/skhd.out.log";
    };
  };
  home.file."${config.xdg.configHome}/skhd/skhdrc".text = ''
    #for debugging
    alt - x :  cmd=$HOME/.local/bin/skhd-run-debug.sh; test -x $cmd && $cmd

    #keywords:
    #https://github.com/koekeishiya/skhd/issues/1
    #
    #Remapping Keys in macOS:
    #https://developer.apple.com/library/archive/technotes/tn2450/
    #https://www.freebsddiary.org/APC/usb_hid_usages.php

    #open a floating terminal
    #❯ alacritty msg create-window -e /bin/zsh -c "exec -c -a -zsh /bin/zsh";
    ralt - return : \
      ${yabai} -m window --insert stack && \
      if [ $(ls ''${TMPDIR}Alacritty-*.sock 2>/dev/null | wc -l) -gt 0 ]; then \
        ${alacritty} msg create-window; \
      else \
        export PATH=$(sed -E 's/:?\/Users\/penglei\/.nix-profile\/bin:?/:/g' <<< $PATH); \
        open -na /Users/penglei/Applications/Alacritty.app; sleep 0.03; \
      fi && ${yabai} -m window --toggle float --grid 8:8:1:1:6:6

    lalt - return : \
      if [ \( $(ls ''${TMPDIR}Alacritty-*.sock 2>/dev/null | wc -l) -gt 0 \) -a \
           \( $(${yabai} -m query --windows --space | ${jq} -r 'if any(.[]; .app == "Alacritty") then "true" else "false" end') = "true" \) ]; \
      then \
        ${alacritty} msg create-window; \
      else \
        #We must clean the home nix-profile/bin from PATH, \
        #so that it would be prepend to PATH in system shell config.\
        export PATH=$(sed -E 's/:?\/$HOME\/.nix-profile\/bin:?/:/g' <<< $PATH); \
        open -na ${pkgs.alacritty}/Applications/Alacritty.app; \
      fi

    #toggle layout between in ('bsp', 'stack', 'float')
    #❯ yabai -m space work --layout float
    lalt + shift - b : ${yabai} -m space --layout "$(${yabai} -m query --spaces --space \
                      | ${jq} -r 'if .type == "bsp" then "float" else if .type == "float" then "stack" else "bsp" end end')" && \
                      ${sketchybar} -m --trigger space_mode_change &> /dev/null

    #focus bsp windows
    lalt - h : ${yabai} -m window --focus west
    lalt - j : ${yabai} -m window --focus south
    lalt - k : ${yabai} -m window --focus north
    lalt - l : ${yabai} -m window --focus east

    #cyclic focus stack windows
    ctrl - right : ${yabai} -m query --spaces --space \
                   | ${jq} -re ".index" \
                   | xargs -I{} ${yabai} -m query --windows --space {} \
                   | ${jq} -sre '.[] | map(select(.minimized != 1)) | sort_by(.display, .frame.y, .frame.x, .id) | reverse | nth(index(map(select(."has-focus" == true))) - 1).id' \
                   | xargs -I{} ${yabai} -m window --focus {}

    #backward
    ctrl - left: ${yabai} -m query --spaces --space \
      | ${jq} -re ".index" \
      | xargs -I{} ${yabai} -m query --windows --space {} \
      | ${jq} -sre '.[] | map(select(.minimized != 1)) | sort_by(.display, .frame.y, .frame.y, .id) | nth(index(map(select(."has-focus" == true))) - 1).id' \
      | xargs -I{} ${yabai} -m window --focus {}

    #swap bsp window (move to target window area and resize) in the same space
    lalt + shift - x : ${yabai} -m window --swap recent
    lalt + shift - h : ${yabai} -m window --swap west
    lalt + shift - j : ${yabai} -m window --swap south
    lalt + shift - k : ${yabai} -m window --swap north
    lalt + shift - l : ${yabai} -m window --swap east
    #move bsp window (keep size but re-arrange relative windows) in the same space
    shift + cmd - left : ${yabai} -m window --warp west
    shift + cmd - down : ${yabai} -m window --warp south
    shift + cmd - up : ${yabai} -m window --warp north
    shift + cmd - right : ${yabai} -m window --warp east

    #move floating window
    ctrl + shift - a : ${yabai} -m window --move rel:-100:0
    ctrl + shift - s : ${yabai} -m window --move rel:-4:100
    ctrl + shift - w : ${yabai} -m window --move rel:0:-100
    ctrl + shift - d : ${yabai} -m window --move rel:100:0

    #make floating window fill top-half of screen
    lalt + shift - up     : ${yabai} -m window --grid 2:1:0:0:1:1
    # make floating window fill bottom-half of screen
    lalt + shift - down   : ${yabai} -m window --grid 2:1:0:1:1:1
    #make floating window fill left-half of screen
    lalt + shift - left   : ${yabai} -m window --grid 1:2:0:0:1:1
    #make floating window fill right-half of screen
    lalt + shift - right  : ${yabai} -m window --grid 1:2:1:0:1:1

    # destroy desktop
    # cmd + lalt - w : ${yabai} -m space --destroy
    # cmd + lalt - w : ${yabai} -m space --focus prev && ${yabai} -m space recent --destroy

    # fast focus desktop
    lalt - backspace : ${yabai} -m space --focus recent
    lalt - left  : ${yabai} -m space --focus $(${yabai} -m query --spaces --space | ${jq} -r 'if .index == 1  then 10 else "prev" end')
    lalt - right : ${yabai} -m space --focus $(${yabai} -m query --spaces --space | ${jq} -r 'if .index == 10 then 1  else "next" end')
    lalt - 1 : ${yabai} -m space --focus 1
    lalt - 2 : ${yabai} -m space --focus 2
    lalt - 3 : ${yabai} -m space --focus 3
    lalt - 4 : ${yabai} -m space --focus 4
    lalt - 5 : ${yabai} -m space --focus 5
    lalt - 6 : ${yabai} -m space --focus 6
    lalt - 7 : ${yabai} -m space --focus 7
    lalt - 8 : ${yabai} -m space --focus 8
    lalt - 9 : ${yabai} -m space --focus 9
    lalt - 0 : ${yabai} -m space --focus 10

    #"Command + m" is traditional shortcut for minimize current window
    #I don't think minimizing a window is needed, instead we can move it to a "temporary" space!
    cmd - m : ${yabai} -m window --space adhoc

    # send window to space and follow focus
    lalt + shift - backspace : ${yabai} -m window --space recent --focus
    lalt + shift - 1 : ${yabai} -m window --space  1 --focus
    lalt + shift - 2 : ${yabai} -m window --space  2 --focus
    lalt + shift - 3 : ${yabai} -m window --space  3 --focus
    lalt + shift - 4 : ${yabai} -m window --space  4 --focus
    lalt + shift - 5 : ${yabai} -m window --space  5 --focus
    lalt + shift - 6 : ${yabai} -m window --space  6 --focus
    lalt + shift - 7 : ${yabai} -m window --space  7 --focus
    lalt + shift - 8 : ${yabai} -m window --space  8 --focus
    lalt + shift - 9 : ${yabai} -m window --space  9 --focus
    lalt + shift - 0 : ${yabai} -m window --space 10 --focus

    # # focus monitor
    # lalt + ctrl - x  : ${yabai} -m display --focus recent
    # lalt + ctrl - z  : ${yabai} -m display --focus prev
    # lalt + ctrl - c  : ${yabai} -m display --focus next
    # lalt + ctrl - 1  : ${yabai} -m display --focus 1
    # lalt + ctrl - 2  : ${yabai} -m display --focus 2
    # lalt + ctrl - 3  : ${yabai} -m display --focus 3

    # send window to monitor and follow focus
    # ctrl + cmd - x  : ${yabai} -m window --display recent
    # ctrl + cmd - 1  : ${yabai} -m window --display 1 --focus
    # ctrl + cmd - 2  : ${yabai} -m window --display 2 --focus

    # resize window
    ralt - r : ${yabai} -m space --balance # resize windows defaultly
    ralt - w : ${yabai} -m window --resize top:0:-100 --resize bottom:0:100
    ralt - s : ${yabai} -m window --resize top:0:100 --resize bottom:0:-100
    ralt - a : ${yabai} -m window --resize left:-100:0 --resize right:100:0
    ralt - d : ${yabai} -m window --resize left:100:0 --resize right:-100:0

    # set new window insertion point in the south of the focused window
    cmd - i : ${yabai} -m window --insert south  #stack,west,east,north,south

    lalt + ctrl - h : ${yabai} -m window --warp west
    lalt + ctrl - j : ${yabai} -m window --warp south
    lalt + ctrl - k : ${yabai} -m window --warp north
    lalt + ctrl - l : ${yabai} -m window --warp east

    # rotate tree
    lalt - r : ${yabai} -m space --rotate 90

    # # mirror tree y-axis
    # lalt - y : ${yabai} -m space --mirror y-axis
    # # mirror tree x-axis
    # lalt - x : ${yabai} -m space --mirror x-axis

    # # toggle window padding andgap
    # lalt - a : ${yabai} -m space --toggle padding --toggle gap

    # # toggle window parent zoom
    # lalt - d : ${yabai} -m window --toggle zoom-parent

    # toggle window fullscreen zoom
    lalt - m : ${yabai} -m window --toggle zoom-fullscreen \
              && ${sketchybar} -m --trigger window_resize &> /dev/null

    # toggle window native fullscreen
    lalt + shift - m : ${yabai} -m window --toggle native-fullscreen

    # # window focus follows mouse cursor
    # lalt + shift - f : sh -c 'config="autoraise"; f="$HOME/.yabai.config.focus_follows_mouse"; \
    #                   if [ "$(cat $f)" == "off" ]; then config="autoraise"; fi; \
    #                   ${yabai} -m config focus_follows_mouse "$config" && printf "$config" > $f'

    #toggle current space windows layout orientation
    #lalt - e : ${yabai} -m window --toggle split

    #float / unfloat window and restore position
    lalt - t : ${yabai} -m window --toggle float --grid 8:8:1:1:6:6

    # toggle sticky (show on all spaces)
    lalt - s : ${yabai} -m window --toggle sticky --toggle topmost --toggle float --grid 8:8:3:0:5:6

    # # toggle opacity
    cmd + shift + alt - o : ${yabai} -m config window_opacity \
              "$(${yabai} -m query --windows | ${jq} -r 'if any(.[]; .opacity < 1) then "off" else "on" end')" \
              && ${sketchybar} -m --trigger opacity_change &> /dev/null

    # # toggle picture-in-picture
    # lalt - p : ${yabai} -m window --toggle border --toggle pip

    # f13: ${skhd} -k "shift + cmd - 4" # Screen Capture: copy screen of selected area to the clipboard

    # #'hyper' is a special key that is a combination of shift + alt + option + command
    # hyper - b: ${sketchybar} --bar topmost="$(${sketchybar} --query bar | ${jq} -r 'if .topmost == "on" then "off" else "on" end')"
  '';
}

