{ config, ... }: {

  home.file."${config.xdg.configHome}/helix/themes" = {
    source = ../files/dotfiles/.config/helix/themes;
  };

  programs.helix = {
    enable = true;
    settings = {
      theme = "catppuccin_macchiato";
      editor = {
        cursorline = true;
        color-modes = true;
        true-color = true;
      };
      editor.cursor-shape = {
        insert = "bar";
        normal = "block";
        select = "underline";
      };
      editor.indent-guides.render = true;
    };
  };
}
