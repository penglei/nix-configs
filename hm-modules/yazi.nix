{
  pkgs,
  lib,
  config,
  ...
}:

#docs: https://yazi-rs.github.io/features/
{
  xdg.configFile = {
    "yazi/theme.toml" = {
      source = ../files/dotfiles/_config/yazi/themes/catppuccin/macchiato/catppuccin-macchiato-sky.toml;
    };
    "yazi/Catppuccin-macchiato.tmTheme" =
      let
        batTheme = config.programs.bat.themes;
        name = "catppuccin";
      in
      lib.mkIf (lib.hasAttr name batTheme) {
        source =
          let
            val = batTheme."${name}";
          in
          "${val.src}/${val.file}";
      };
  };
  home.shellAliases = {
    "y" = "yazi";
  };
  programs.yazi = {
    enable = true;
    shellWrapperName = "yy";
    settings = {
      mgr = {
        ratio = [
          1
          2
          4
        ];
        sort_by = "natural";
        sort_dir_first = true;
      };
      priview.wrap = "yes";
      plugin.prepend_fetchers = [
        {
          id = "git";
          name = "*";
          run = "git";
        }

        {
          id = "git";
          name = "*/";
          run = "git";
        }
      ];
      plugin.prepend_previewers = [
        {
          mime = "application/{,g}zip";
          run = "lsar";
        }
        {
          mime = "application/x-{tar,bzip*,7z-compressed,xz,rar}";
          run = "lsar";
        }
      ];
    };

    keymap.manager.prepend_keymap = [
      # Smart paste plugin
      {
        on = "p";
        run = "plugin smart-paste";
      }

      # File navigation wraparound plugin
      {
        on = "k";
        run = "plugin arrow --args=-1";
      }
      {
        on = "j";
        run = "plugin arrow --args=1";
      }

      # Max preview
      {
        on = "T";
        run = "plugin max-preview";
      }

      # Bookmarks
      {
        on = "m";
        run = "plugin bookmarks --args=save";
      }
      {
        on = "'";
        run = "plugin bookmarks --args=jump";
      }
      {
        on = "`";
        run = "plugin bookmarks --args=jump";
      }
      {
        on = [
          "b"
          "d"
        ];
        run = "plugin bookmarks --args=delete";
      }

      #fg
      {
        on = [
          "f"
          "g"
        ];
        run = "plugin fg";
        desc = "find file by content (fuzzy match)";
      }
      {
        on = [
          "f"
          "G"
        ];
        run = "plugin fg --args='rg'";
        desc = "find file by content (ripgrep match)";
      }
      {
        on = [
          "f"
          "f"
        ];
        run = "plugin fg --args='fzf'";
        desc = "find file by filename";
      }
    ];
    initLua = ../files/dotfiles/_config/yazi/init.lua;
    plugins = {
      inherit (pkgs.yazi-plugins)
        full-border
        git
        max-preview
        lsar
        bookmarks
        fg
        ;
      "smart-paste" = ../files/dotfiles/_config/yazi/plugins/smart-paste.yazi;
      "arrow" = ../files/dotfiles/_config/yazi/plugins/arrow.yazi;
    };
  };
}
