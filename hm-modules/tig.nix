{
  home.file.".tigrc".text = ''
    set vertical-split = horizontal
    bind generic 9 !@sh -c "echo -n %(commit) | pbcopy"
    bind generic 9 !@sh -c "git rev-parse --short %(commit) | tr -d '\\r\\n' | pbcopy"
  '';
}
