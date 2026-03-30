{
  home.file.".tigrc".text = ''
    set vertical-split = horizontal
    bind generic 9 !@sh -c "echo -n %(commit) | pbcopy"
    bind generic 0 !@sh -c "git rev-parse --short %(commit) | tr -d '\\r\\n' | pbcopy"

    color cursor white black bold
    color cursor-blur white 172 bold

    color title-focus white black bold
    color title-blur white 235

    color status white black
  '';
}
