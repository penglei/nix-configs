{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fontconfig

    #monaspace ##original Monaspace
    # Five matching fonts all having 'texture healing' to improve legibility.
    # Monaspace font icons size fits best in terminal.
    nerd-fonts.monaspace

    #cascadia-code ##original Cascadia Code
    # A fun, new monospaced font that includes programming ligatures
    # and is designed to enhance the modern look and feel of the Windows Terminal
    nerd-fonts.caskaydia-cove
    # Like Cascadia Code but without any ligatures
    nerd-fonts.caskaydia-mono

    #monoid ##original Monoid
    # Ligatures, distinguishable glyphs with short ascenders & descenders, large operators & punctuation
    nerd-fonts.monoid

    #dejavu_fonts ###original DejaVu Sans Mono
    # Dotted zero, based on the Bitstream Vera Fonts with a wider range of character
    nerd-fonts.dejavu-sans-mono

    #fira-code fira-math fira-mono #... ##original Fira font famliy
    # Programming ligatures, extension of Fira Mono font, enlarged operators
    nerd-fonts.fira-code

    #jetbrains-mono ##original JetBrains
    # JetBrains officially created font for developers
    nerd-fonts.jetbrains-mono

    # #hack-font ##original Hack font
    # # Dotted zero, short descenders, expands upon work done for Bitstream Vera & DejaVu, legible at common sizes
    # nerd-fonts.hack

    font-awesome
    #twemoji-color-font

    #^Customizations
    #droidsans_fonts
    #hack-nerd-font
    #apple-sfmono-font
    #apple-sfmono-nerd-font

    # a monospaced font with reasonable Unicode support.
    julia-mono

    # texlive 字体说明:
    #   texlive 需要一些字体如STFangsong、Kaiti，这些字体文件在nix texlive fontconfig的查找路径中是不存在的。
    #   因此我们需要手动将相应的字体文件拷贝到 ~/Library/Fonts 或 ~/.local/share/fonts/ 目录(当前这个module没有自动做这个事情)。
  ];

  #可以使用fontconfig的`fc-list`来浏览字体。为了让这个命令找到系统自带的字体，
  #需要配置系统字体存放的路径。注意这些目录在不同的MacOS版本中可能不同。
  xdg.configFile."fontconfig/conf.d/20-os-fonts.conf".text = ''
    <?xml version='1.0'?>
    <!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
    <fontconfig>
      <dir>/System/Library/Fonts</dir>
      <dir>/System/Library/Fonts/Supplemental</dir>
      <dir>/Library/Fonts</dir>
      <dir>/System/Library/PrivateFrameworks/FontServices.framework/Resources/Fonts</dir>
    </fontconfig>
  '';
}
