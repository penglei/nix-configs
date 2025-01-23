{ pkgs, config, ... }:

let
  homeProfilePath = path: "${config.home.homeDirectory}/${path}";
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
        # "PATH" = "${homeProfilePath ".nix-profile/bin"}:${homeProfilePath ".local/bin"}:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:";
        "PATH" = "${
            homeProfilePath ".local/bin"
          }:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:";
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
    #debug
    #alt - x : wmshow yabai tiling::window --close #

    #keywords:
    #https://github.com/koekeishiya/skhd/issues/1
    #
    #Remapping Keys in macOS
    #https://developer.apple.com/library/archive/technotes/tn2450/
    #https://www.freebsddiary.org/APC/usb_hid_usages.php


    #  alacritty msg create-window -e /bin/zsh -c "exec -c -a -zsh /bin/zsh";
    #open a floating terminal
    hyper - return : \
                   ${yabai} -m window --insert stack && \
                   if [ $(ls ''${TMPDIR}Alacritty-*.sock 2>/dev/null | wc -l) -gt 0 ]; then \
                     ${alacritty} msg create-window; \
                   else \
                     open -na /Users/penglei/Applications/Alacritty.app; sleep 0.03; \
                   fi && \
                   ${yabai} -m window --toggle float --grid 8:8:1:1:6:6
    alt - return : \
      if [ \( $(ls ''${TMPDIR}Alacritty-*.sock 2>/dev/null | wc -l) -gt 0 \) -a \( $(${yabai} -m query --windows --space | ${jq} -r 'if any(.[]; .app == "Alacritty") then "true" else "false" end') = "true" \) ]; then \
        ${alacritty} msg create-window; \
      else \
        open -na ${pkgs.alacritty}/Applications/Alacritty.app; \
      fi

    # yabai -m space work --layout float
    # toggle layout between 'bsp', 'stack', 'float'.
    #alt + rshift - b :
    alt + shift - b : ${yabai} -m space --layout "$(${yabai} -m query --spaces --space | ${jq} -r 'if .type == "bsp" then "float" else if .type == "float" then "stack" else "bsp" end end')" && \
                       ${sketchybar} -m --trigger space_mode_change &> /dev/null


    # focus bsp windows
    alt - h : ${yabai} -m window --focus west
    alt - j : ${yabai} -m window --focus south
    alt - k : ${yabai} -m window --focus north
    alt - l : ${yabai} -m window --focus east

    # cyclic focus stack windows
    ctrl - right : ${yabai} -m query --spaces --space \
      | ${jq} -re ".index" \
      | xargs -I{} ${yabai} -m query --windows --space {} \
      | ${jq} -sre '.[] | map(select(.minimized != 1)) | sort_by(.display, .frame.y, .frame.x, .id) | reverse | nth(index(map(select(."has-focus" == true))) - 1).id' \
      | xargs -I{} ${yabai} -m window --focus {}

    # backward
    ctrl - left: ${yabai} -m query --spaces --space \
      | ${jq} -re ".index" \
      | xargs -I{} ${yabai} -m query --windows --space {} \
      | ${jq} -sre '.[] | map(select(.minimized != 1)) | sort_by(.display, .frame.y, .frame.y, .id) | nth(index(map(select(."has-focus" == true))) - 1).id' \
      | xargs -I{} ${yabai} -m window --focus {}

    # swap bsp window (move to target window area and resize)
    alt + shift - x : ${yabai} -m window --swap recent
    alt + shift - h : ${yabai} -m window --swap west
    alt + shift - j : ${yabai} -m window --swap south
    alt + shift - k : ${yabai} -m window --swap north
    alt + shift - l : ${yabai} -m window --swap east
    # move bsp window (keep size but re-arrange relative windows)
    shift + cmd - left : ${yabai} -m window --warp west
    shift + cmd - down : ${yabai} -m window --warp south
    shift + cmd - up : ${yabai} -m window --warp north
    shift + cmd - right : ${yabai} -m window --warp east

    # move floating window
    ctrl + shift - a : ${yabai} -m window --move rel:-100:0
    ctrl + shift - s : ${yabai} -m window --move rel:0:100
    ctrl + shift - w : ${yabai} -m window --move rel:0:-100
    ctrl + shift - d : ${yabai} -m window --move rel:100:0
    # make floating window fill top-half of screen
    alt + shift - up     : ${yabai} -m window --grid 2:1:0:0:1:1
    # make floating window fill bottom-half of screen
    alt + shift - down   : ${yabai} -m window --grid 2:1:0:1:1:1
    # make floating window fill left-half of screen
    alt + shift - left   : ${yabai} -m window --grid 1:2:0:0:1:1
    # make floating window fill right-half of screen
    alt + shift - right  : ${yabai} -m window --grid 1:2:1:0:1:1

    # destroy desktop
    # cmd + alt - w : ${yabai} -m space --destroy
    # cmd + alt - w : ${yabai} -m space --focus prev && ${yabai} -m space recent --destroy

    # fast focus desktop
    alt - backspace : ${yabai} -m space --focus recent
    alt - left  : ${yabai} -m space --focus $(${yabai} -m query --spaces --space | ${jq} -r 'if .index == 1  then 10 else "prev" end')
    alt - right : ${yabai} -m space --focus $(${yabai} -m query --spaces --space | ${jq} -r 'if .index == 10 then 1  else "next" end')
    alt - 1 : ${yabai} -m space --focus  1
    alt - 2 : ${yabai} -m space --focus  2
    alt - 3 : ${yabai} -m space --focus  3
    alt - 4 : ${yabai} -m space --focus  4
    alt - 5 : ${yabai} -m space --focus  5
    alt - 6 : ${yabai} -m space --focus  6
    alt - 7 : ${yabai} -m space --focus  7
    alt - 8 : ${yabai} -m space --focus  8
    alt - 9 : ${yabai} -m space --focus  9
    alt - 0 : ${yabai} -m space --focus  10
    #cmd - 0 : ${yabai} -m space --focus  adhoc
    #hyper - 1 : ${yabai} -m space --focus  1
    #hyper - 2 : ${yabai} -m space --focus  2
    #hyper - 3 : ${yabai} -m space --focus  3
    #hyper - 4 : ${yabai} -m space --focus  4

    #"Command + m" is traditional shortcut for minimize current window
    #I don't think minimizing a window is needed, instead we can move it to a "hidden" space!
    cmd - m : ${yabai} -m window --space adhoc

    #"alt + shift" prefix is used to move window around spaces,
    #the frequent ordinary operation in adhoc space is move out window,
    #so we can keep 'shift' key to reduce modifier key switch between 'alt + shift' and 'alt'.
    alt + shift - 0 : ${yabai} -m space --focus adhoc

    # send window to desktop and follow focus
    alt + shift - backspace : ${yabai} -m window --space recent && ${yabai} -m space --focus recent
    alt + shift - left : ${yabai} -m window --space prev && ${yabai} -m space --focus prev
    alt + shift - right : ${yabai} -m window --space next && ${yabai} -m space --focus next
    alt + shift - 1 : ${yabai} -m window --space  1 && ${yabai} -m space --focus 1
    alt + shift - 2 : ${yabai} -m window --space  2 && ${yabai} -m space --focus 2
    alt + shift - 3 : ${yabai} -m window --space  3 && ${yabai} -m space --focus 3
    alt + shift - 4 : ${yabai} -m window --space  4 && ${yabai} -m space --focus 4
    alt + shift - 5 : ${yabai} -m window --space  5 && ${yabai} -m space --focus 5
    alt + shift - 6 : ${yabai} -m window --space  6 && ${yabai} -m space --focus 6
    alt + shift - 7 : ${yabai} -m window --space  7 && ${yabai} -m space --focus 7
    alt + shift - 8 : ${yabai} -m window --space  8 && ${yabai} -m space --focus 8
    alt + shift - 9 : ${yabai} -m window --space  9 && ${yabai} -m space --focus 9
    alt + shift - 0 : ${yabai} -m window --space  9 && ${yabai} -m space --focus 10

    # # focus monitor
    # alt + ctrl - x  : ${yabai} -m display --focus recent
    # alt + ctrl - z  : ${yabai} -m display --focus prev
    # alt + ctrl - c  : ${yabai} -m display --focus next
    # alt + ctrl - 1  : ${yabai} -m display --focus 1
    # alt + ctrl - 2  : ${yabai} -m display --focus 2
    # alt + ctrl - 3  : ${yabai} -m display --focus 3
    #
    # # send window to monitor and follow focus
    # ctrl + cmd - x  : ${yabai} -m window --display recent && ${yabai} -m display --focus recent
    # ctrl + cmd - z  : ${yabai} -m window --display prev && ${yabai} -m display --focus prev
    # ctrl + cmd - c  : ${yabai} -m window --display next && ${yabai} -m display --focus next
    # ctrl + cmd - 1  : ${yabai} -m window --display 1 && ${yabai} -m display --focus 1
    # ctrl + cmd - 2  : ${yabai} -m window --display 2 && ${yabai} -m display --focus 2
    # ctrl + cmd - 3  : ${yabai} -m window --display 3 && ${yabai} -m display --focus 3
    # balance size of windows
    alt + shift - r : ${yabai} -m space --balance
    #resize window
    #alt + shift - w : ${yabai} -m window --resize top:0:-100 --resize bottom:0:100
    #alt + shift - s : ${yabai} -m window --resize top:0:100 --resize bottom:0:-100
    #alt + shift - a : ${yabai} -m window --resize left:-100:0 --resize right:100:0
    #alt + shift - d : ${yabai} -m window --resize left:100:0 --resize right:-100:0
    hyper - w : ${yabai} -m window --resize top:0:-100 --resize bottom:0:100
    hyper - s : ${yabai} -m window --resize top:0:100 --resize bottom:0:-100
    hyper - a : ${yabai} -m window --resize left:-100:0 --resize right:100:0
    hyper - d : ${yabai} -m window --resize left:100:0 --resize right:-100:0

    ## set insertion point in focused container
    cmd - i : ${yabai} -m window --insert south  #stack,west,east,north,south

    alt + ctrl - h : ${yabai} -m window --warp west
    alt + ctrl - j : ${yabai} -m window --warp south
    alt + ctrl - k : ${yabai} -m window --warp north
    alt + ctrl - l : ${yabai} -m window --warp east

    # rotate tree
    alt - r : ${yabai} -m space --rotate 90

    # mirror tree y-axis
    alt - y : ${yabai} -m space --mirror y-axis

    # mirror tree x-axis
    alt - x : ${yabai} -m space --mirror x-axis

    # toggle desktop offset
    alt - a : ${yabai} -m space --toggle padding --toggle gap

    # toggle window parent zoom
    # alt - d : ${yabai} -m window --toggle zoom-parent

    # toggle window fullscreen zoom
    alt - m : ${yabai} -m window --toggle zoom-fullscreen && ${sketchybar} -m --trigger window_resize &> /dev/null

    # toggle window native fullscreen
    alt + shift - m : ${yabai} -m window --toggle native-fullscreen

    alt + shift - f : sh -c 'config="autoraise"; f="$HOME/.yabai.config.focus_follows_mouse"; \
                      if [ "$(cat $f)" == "off" ]; then config="autoraise"; fi; \
                      ${yabai} -m config focus_follows_mouse "$config" && printf "$config" > $f'


    # toggle window split type
    alt - e : ${yabai} -m window --toggle split

    # float / unfloat window and restore position
    lalt - t : ${yabai} -m window --toggle float --grid 8:8:1:1:6:6

    # toggle sticky (show on all spaces)
    alt - s : ${yabai} -m window --toggle sticky --toggle topmost --toggle float --grid 8:8:3:0:5:6

    # toggle opacity
    alt - o : ${yabai} -m config window_opacity "$(${yabai} -m query --windows | ${jq} -r 'if any(.[]; .opacity < 1) then "off" else "on" end')" \
              && ${sketchybar} -m --trigger opacity_change &> /dev/null

    # toggle picture-in-picture
    alt - p : ${yabai} -m window --toggle border --toggle pip

    ctrl + shift + alt + cmd - k : update-yabai-unmanaged-apps add
    ctrl + shift + alt + cmd - l : update-yabai-unmanaged-apps delete

    f13: ${skhd} -k "shift + cmd - 4" # Screen Capture: copy screen of selected area to the clipboard

    hyper - b: ${sketchybar} --bar topmost="$(${sketchybar} --query bar | ${jq} -r 'if .topmost == "on" then "off" else "on" end')"

  '';
}

