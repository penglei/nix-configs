{ config, pkgs, lib, ... }: {
  home.language = rec {
    base = "en_US.UTF-8";
    ctype = base;
    time = base;
  };

  home.sessionPath = [ "$HOME/.local/bin" "$HOME/.local/share/nvim/mason/bin" ];

  home.shellAliases = {
    ls = "ls --color";
    ll = "ls -lh";
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    k = "kubectl";
  };

  fonts.fontconfig.enable = true;
}

