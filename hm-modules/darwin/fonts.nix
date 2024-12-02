{ pkgs, ... }: {
  home.packages = with pkgs; [
    fontconfig

    #{--coding font
    # (nerdfonts.override {
    #   fonts = [
    #     #prefer ** (<most width>, <ligatures>)
    #     "FiraCode"

    #     #prefer ** (<most narrow>, <ligatures>)
    #     "JetBrainsMono"

    #     #prefer *** (<narrow>, <no-ligatures>)
    #     "DejaVuSansMono"

    #     #prefer *** (<narrow>, <no-ligatures>)
    #     #derived from DejaVuSansMono
    #     "Hack"

    #     "DroidSansMono"
    #     "Monoid"
    #   ];
    # })
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.dejavu-sans-mono
    nerd-fonts.hack
    nerd-fonts.monoid

    #^custom Hack
    #some symbols not exist which are needed by neovim NvChad(😣).
    #hack-nerd-font

    #jetbrains-mono

    #apple-sfmono-font
    apple-sfmono-nerd-font

    #--}

    font-awesome_5
    font-awesome_6

    #sarasa-gothic
    #(iosevka-bin.override { variant = "slab"; })

    #noto-fonts-emoji

    twemoji-color-font

    dejavu_fonts

    #^custom
    droidsans_fonts
  ];

  #texlive 需要的一些字体如STFangsong、Kaiti，这些字体文件在nix texlive fontconfig查找路径中是没有的。
  #我们需要将相应的字体文件拷贝到 ~/Library/Fonts 或 ~/.local/share/fonts/ 目录。
  #为了方便找到字体目录，我们把配置一些系统字体的查找路径，方便使用fc-list查找需要的字体。
  #另外，MacOS不同版本可能这些目录可能会变.
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
