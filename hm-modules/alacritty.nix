{ pkgs, lib, config, ... }:

let
  fontoffsetbase = {
    x = 0;
    y = -1; # line spacing delta
  };
  fontcfgstyle = {
    firacode = {
      family = "FiraCode Nerd Font Mono";
      style = "Light";
      offset = fontoffsetbase // { y = -1; };
    };
  };
  #font:
  #  normal:
  #    family: FiraCode Nerd Font Mono
  #
  #family: FiraCode Nerd Font
  #family: FiraCode Nerd Font Mono
  #style: Light
  ##
  #family: JetBrainsMono Nerd Font
  #family: JetBrainsMono Nerd Font Mono
  #style: Light
  ##
  #family: Hack Nerd Font
  #family: Hack Nerd Font Mono #(↑ 没区别)
  ##
  #family: DejaVuSansMono Nerd Font
  #family: DejaVuSansMono Nerd Font Mono #(↑ 没区别)
  ##
  #family: SFMono Nerd Font
  #style: Light

  ##FiraCode, JetBrains的行高类似，都比较高
  ##Hack, DejaVu,SF的行高类似，都稍微矮一点
  ##命令行里面感觉行高一点看起来舒服些

  font = fontcfgstyle.firacode;

  userlocalconfigfile =
    "${config.xdg.configHome}/alacritty/userlocal.toml"; # "~/.config/alacritty/userlocal.toml";
in {
  #home.activation.writerMutableAllcrittyConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #  touch ${userlocalconfigfile}
  #  ${pkgs.yq-go}/bin/yq -i '.font.normal.family = "${font.family}"' ${userlocalconfigfile}
  #  if [[ -n "${font.style}" ]]; then
  #    ${pkgs.yq-go}/bin/yq -i '.font.normal.style = "${font.style}"' ${userlocalconfigfile}
  #  fi
  #  ${pkgs.yq-go}/bin/yq -i '.font.offset.y = ${toString(font.offset.y)}' ${userlocalconfigfile}
  #'';

  programs.alacritty = {
    enable = true;
    settings = {
      general.import = [ userlocalconfigfile ];
      window = {
        option_as_alt = "OnlyLeft";
        decorations = "buttonless";
        opacity = 1.0;
        startup_mode = "Maximized";
        title = "😄";
        dynamic_title = true;
      };
      font = {
        normal = {
          ##config in userlocal.yml
          #family = "Hack Nerd Font" # "FiraCode Nerd Font Mono" "DejaVuSansMono Nerd Font Mono" 
          #style = "Light"; #Light Regular Bold
        };
        size = 18.0;
      };
      keyboard.bindings = [
        {
          key = "Space";
          mods = "Control";
          mode = "~Search";
          action = "ToggleViMode";
        }
        {
          key = "N";
          mods = "Command";
          action = "CreateNewWindow";
        }
        # { key = "F"; mods = "Alt"; chars = "\\ef"; }
        # { key = "B"; mods = "Alt"; chars = "\\eb"; }
        # { key = "H"; mods = "Alt"; chars = "\\eb"; }
        # { key = "D"; mods = "Alt"; chars = "\\ed"; }
        # { key = "Q"; mods = "Alt"; chars = "\\eq"; }
        # { key = "I"; mods = "Alt"; chars = "\\ei"; }   #nvim toggle float terminal
        # { key = "V"; mods = "Alt"; chars = "\\ev"; }   #nvim toggle vertial terminal
        # { key = "H"; mods = "Alt"; chars = "\\eh"; }   #nvim toggle horizontal terminal
      ];

      hints = {
        enabled = [
          {
            regex = "file:///nix/store/.+ghc.+-doc/.+/html/[^)\\n\\r\\t ]+";
            command = {
              program = "${pkgs.open-haskell-doc}/bin/open-haskell-doc";
            };
            hyperlinks = true;
            post_processing = true;
            mouse = {
              enabled = true;
              mods = "None";
            };
            binding = {
              key = "U";
              mods = "Control|Shift";
            };
          }
          {
            regex = ''
              (ipfs:|ipns:|magnet:|mailto:|gemini:|gopher:|https:|http:|news:|file:|git:|ssh:|ftp:)[^\u0000-\u001F\u007F-\u009F<>"\\s{-}\\^⟨⟩`]+'';
            command = {
              program = "open";
              args = [ "-n" "-a" "Google Chrome" "--args" ];
            };
            hyperlinks = true;
            post_processing = true;
            mouse = {
              enabled = true;
              mods = "None";
            };
            binding = {
              key = "U";
              mods = "Control|Shift";
            };
          }
        ];
      };
    };
  };
}
