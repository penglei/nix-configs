{ lib, config, ... }:

#docs: https://yazi-rs.github.io/features/
{
  home.shellAliases = { "y" = "yazi"; };
  programs.yazi = {
    enable = true;
    shellWrapperName = "yy";
    settings = {
      manager.ratio = [ 1 2 4 ];
      priview.wrap = "yes";
    };
  };
  xdg.configFile = {
    "yazi/theme.toml" = {
      source =
        ../files/dotfiles/.config/yazi/themes/catppuccin/macchiato/catppuccin-macchiato-sky.toml;
    };
    "yazi/Catppuccin-macchiato.tmTheme" = let
      batTheme = config.programs.bat.themes;
      name = "catppuccin";
    in lib.mkIf (lib.hasAttr name batTheme) {
      source = let val = batTheme."${name}"; in "${val.src}/${val.file}";
    };
  };
}
