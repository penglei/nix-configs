{
  home.file.".tigrc".text = ''
    set vertical-split = horizontal
    bind generic 9 !@sh -c "echo -n %(commit) | pbcopy"
    bind generic 0 !@sh -c "git rev-parse --short %(commit) | tr -d '\\r\\n' | pbcopy"

    # 光标/选中行
    color cursor white black bold
    color cursor-blur white 172 bold  #选中的commit橘色背景

    # 标题栏
    color title-focus white black bold
    color title-blur white 235

    # 状态栏
    color status white black
  '';
}
