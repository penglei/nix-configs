{ lib, config, ... }:
let
  homeDir = config.home.homeDirectory;
  configText = ''
    [General]
    auto_backup=false
    first_run=false
    language=zh_cn
    start_on_boot=true

    [Hotkey]
    custom_snip=
    hide=
    paste=
    snip="335544385, 335544320"
    snip_and_copy=
    switch=

    [Output]
    auto_save_path=${homeDir}/Pictures/snipaste/$yyyy-MM-dd_HH-mm-ss$.png
    quick_save_path=${homeDir}/Pictures/snipaste/$yyyy-MM-dd_HH-mm-ss$.png

    [Snip]
    auto_save=true

    [Update]
    check_on_start=false
  '';
in {

  home.file.".snipaste/.config.ini.link".text = configText;
  home.activation.CreateSnipasteConfig =
    lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      # if [ -f $HOME/.snipaste/.config.ini.link  ];then
        cat $HOME/.snipaste/.config.ini.link > $HOME/.snipaste/config.ini
      # fi
    '';
}
