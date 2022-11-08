{ pkgs, ... }:

{

  home.file = {
    ".config/alacritty/themes" = {
      source = ../files/dotfiles/_config/alacritty/themes;
    };
    ".config/alacritty/userlocal.toml" = {
      source = ../files/dotfiles/_config/alacritty/userlocal.toml;
    };
  };
  programs.alacritty = {
    enable = true;
    settings = {
      general.import = [
        "~/.config/alacritty/userlocal.toml"
        "~/.config/alacritty/themes/catppuccin-macchiato.toml"
      ];
      window = {
        option_as_alt = "OnlyLeft";
        decorations = "buttonless";
        opacity = 1.0;
        startup_mode = "Maximized";
        title = ""; # nf-cod-smiley
        dynamic_title = true;
      };
      font = {
        normal = { }; # configure in userlocal.yml
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
