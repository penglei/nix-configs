{ lib, pkgs, config, ... }:

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
  home.file."${config.xdg.configHome}/skhd/switch-space.sh".source =
    ../../files/dotfiles/_config/skhd/switch-space.sh;
  home.file."${config.xdg.configHome}/skhd/win-hfocus.sh".source =
    ../../files/dotfiles/_config/skhd/win-hfocus.sh;
  home.file."${config.xdg.configHome}/skhd/win-vfocus.sh".source =
    ../../files/dotfiles/_config/skhd/win-vfocus.sh;
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
        export PATH=$(sed -E 's/:?${
          lib.strings.escape [ "/" ] config.home.homeDirectory
        }\/.nix-profile\/bin:?/:/g' <<< $PATH); \
        open -na $HOME/Applications/Alacritty.app; sleep 0.03; \
      fi && ${yabai} -m window --toggle float --grid 8:8:1:1:6:6

    lalt - return : \
      if [ \( $(ls ''${TMPDIR}Alacritty-*.sock 2>/dev/null | wc -l) -gt 0 \) -a \
           \( $(${yabai} -m query --windows --space | ${jq} -r 'if any(.[]; .app == "Alacritty") then "true" else "false" end') = "true" \) ]; \
      then \
        ${alacritty} msg create-window; \
      else \
        #We must clean the NIX_PROFILES PATH, \
        #so that it would be prepend to PATH in system shell config.\
        export PATH=$(sed -E "s|:?$HOME/.nix-profile/bin:?|:|g" <<< $PATH); \
        export PATH=$(sed -E "s|:?/nix/var/nix/profiles/default:?|:|g" <<< $PATH); \
        open -na ${pkgs.alacritty}/Applications/Alacritty.app; \
      fi

    #toggle layout between in ('bsp', 'stack', 'float')
    #❯ yabai -m space work --layout float
    lalt + shift - b : ${yabai} -m space --layout "$(${yabai} -m query --spaces --space \
                      | ${jq} -r 'if .type == "bsp" then "float" else if .type == "float" then "stack" else "bsp" end end')" && \
                      ${sketchybar} -m --trigger space_mode_change &> /dev/null

    #focus bsp windows (yabai -m window --focus north, east, south, west)
    lalt - k : $HOME/.config/skhd/win-vfocus.sh north
    lalt - l : $HOME/.config/skhd/win-hfocus.sh east
    lalt - j : $HOME/.config/skhd/win-vfocus.sh south
    lalt - h : $HOME/.config/skhd/win-hfocus.sh west

    #swap bsp window (move to target window area and resize) in the same space
    lalt + shift - h : ${yabai} -m window --warp west
    lalt + shift - j : ${yabai} -m window --warp south
    lalt + shift - k : ${yabai} -m window --warp north
    lalt + shift - l : ${yabai} -m window --warp east
    lalt + ctrl - h : ${yabai} -m window --swap west
    lalt + ctrl - j : ${yabai} -m window --swap south
    lalt + ctrl - k : ${yabai} -m window --swap north
    lalt + ctrl - l : ${yabai} -m window --swap east
    #lalt + ctrl - x : ${yabai} -m window --swap recent

    #move floating window
    ctrl + shift - a : ${yabai} -m window --move rel:-100:0
    ctrl + shift - s : ${yabai} -m window --move rel:-4:100
    ctrl + shift - w : ${yabai} -m window --move rel:0:-100
    ctrl + shift - d : ${yabai} -m window --move rel:100:0

    # #make floating window fill top-half of screen
    # lalt + shift - up     : ${yabai} -m window --grid 2:1:0:0:1:1
    # # make floating window fill bottom-half of screen
    # lalt + shift - down   : ${yabai} -m window --grid 2:1:0:1:1:1
    # #make floating window fill left-half of screen
    # lalt + shift - left   : ${yabai} -m window --grid 1:2:0:0:1:1
    # #make floating window fill right-half of screen
    # lalt + shift - right  : ${yabai} -m window --grid 1:2:1:0:1:1

    # fast focus space
    lalt - backspace : $HOME/.config/skhd/switch-space.sh recent
    lalt - left  : $HOME/.config/skhd/switch-space.sh $(${yabai} -m query --spaces --space | ${jq} -r 'if .index == 1  then 10 else "prev" end')
    lalt - right : $HOME/.config/skhd/switch-space.sh $(${yabai} -m query --spaces --space | ${jq} -r 'if .index == 10 then 1  else "next" end')
    lalt - 1 : $HOME/.config/skhd/switch-space.sh 1
    lalt - 2 : $HOME/.config/skhd/switch-space.sh 2
    lalt - 3 : $HOME/.config/skhd/switch-space.sh 3
    lalt - 4 : $HOME/.config/skhd/switch-space.sh 4
    lalt - 5 : $HOME/.config/skhd/switch-space.sh 5
    lalt - 6 : $HOME/.config/skhd/switch-space.sh 6
    lalt - 7 : $HOME/.config/skhd/switch-space.sh 7
    lalt - 8 : $HOME/.config/skhd/switch-space.sh 8
    lalt - 9 : $HOME/.config/skhd/switch-space.sh 9
    lalt - 0 : $HOME/.config/skhd/switch-space.sh 10

    #"Command + m" is traditional shortcut for minimize current window
    #I don't think minimizing a window is needed, instead we can move it to a "temporary" space!
    cmd - m : ${yabai} -m window --space adhoc

    # toggle window fullscreen zoom
    lalt - m : ${yabai} -m window --toggle zoom-fullscreen \
              && ${sketchybar} -m --trigger window_resize &> /dev/null

    # toggle window native fullscreen
    lalt + shift - m : ${yabai} -m window --toggle native-fullscreen

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

    #toggle current space windows layout orientation
    #lalt - e : ${yabai} -m window --toggle split

    #float / unfloat window and restore position
    lalt - t : ${yabai} -m window --toggle float --grid 8:8:1:1:6:6

    # toggle sticky (show on all spaces)
    lalt - s : ${yabai} -m window --toggle sticky --toggle float --grid 8:8:3:0:5:6

    # # toggle opacity
    cmd + shift + alt - o : ${yabai} -m config window_opacity \
              "$(${yabai} -m query --windows | ${jq} -r 'if any(.[]; .opacity < 1) then "off" else "on" end')" \
              && ${sketchybar} -m --trigger opacity_change &> /dev/null

    # # toggle picture-in-picture
    # lalt - p : ${yabai} -m window --toggle border --toggle pip

    # f13: ${skhd} -k "shift + cmd - 4" # Screen Capture: copy screen of selected area to the clipboard
  '';
}

