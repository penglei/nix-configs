{ pkgs, ... }: {

  home.file = {
    ".config/rio/themes".source = ../files/dotfiles/_config/rio/themes;
  };

  programs.rio = {
    enable = true;
    settings = {
      theme = "catppuccin-macchiato";
      "option-as-alt" = "left";

      "confirm-before-quit" = false;

      editor = {
        program = "${pkgs.neovim}/bin/nvim";
        args = [ ];
      };

      window = {
        decorations = "Buttonless";
        blur = true;
      };

      fonts = {
        size = 18;
        regular = { family = "MonaspiceNe Nerd Font"; };
      };

      cursor.blinking = false;

      bindings.keys = [
        {
          key = "-";
          "with" = "option";
          action = "SplitDown";
        }
        {
          key = "|";
          "with" = "option";
          action = "SplitRight";
        }
      ];

      navigation = {
        mode = "Bookmark";
        "hide-if-single" = false;
      };
    };
  };
}
