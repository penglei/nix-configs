# Try press the following keys in shell:
# C-r, C-t, A-c

let
  defaultOptions = [
    "--height 90%"
    "--reverse"
    "--bind up:preview-up,down:preview-down"

    "--color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796"
    "--color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6"
    "--color=marker:#b7bdf8,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796"
    "--color=selected-bg:#494d64"
    "--multi"
  ];
in {
  programs.skim = {
    enable = true;
    defaultOptions = defaultOptions;
    fileWidgetCommand = "fd --type f";
    changeDirWidgetOptions = [ "--preview 'tree -C {} | head -200'" ];
  };

  programs.fzf = {
    enable = false;
    defaultOptions = defaultOptions;
    historyWidgetOptions = [ "--sort" "--exact" ];
    changeDirWidgetOptions = [ "--preview 'tree -C {} | head -200'" ];
  };
}

