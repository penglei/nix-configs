{ pkgs, config, ... }:
let
  lib = pkgs.lib;
  cfg = config.programs.zsh;
  zshcfg = let
    relToDotDir = file:
      (lib.optionalString (cfg.dotDir != null) (cfg.dotDir + "/")) + file;
  in {
    pluginsDir =
      if cfg.dotDir != null then relToDotDir "plugins" else ".zsh/plugins";
    plugins = cfg.plugins;
  };
in {
  home.packages = [ pkgs.nix-zsh-completions ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autocd = true;
    defaultKeymap = "emacs";
    history = {
      size = 500000;
      save = 500000;
      path = "$HOME/.zsh_nix_history";
      #Statistic on the frequency of commands:
      #❯ export LC_ALL='C'; cat $HOME/.zsh_nix_history | awk '{print $1}' | sort | uniq -c | sort -s -n -k 1,1
    };
    plugins = [
      {
        name = "omz-completion";
        file = "lib/completion.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "ohmyzsh";
          repo = "ohmyzsh";
          rev = "6df14641ac48b380c56e1c72aa86b57861fbfb70";
          sha256 = "sha256-bfaeszprKsaiPUhR8+QOtrLC57Dy3JOhXzntokkhLSI=";
        };
      }
      {
        name = "zsh-autopair";
        src = pkgs.fetchFromGitHub {
          owner = "hlissner";
          repo = "zsh-autopair";
          rev = "396c38a7468458ba29011f2ad4112e4fd35f78e6";
          sha256 = "sha256-PXHxPxFeoYXYMOC29YQKDdMnqTO0toyA7eJTSCV6PGE=";
        };
      }
    ];
    envExtra = "";
    initExtra = ''
      bindkey "^U" backward-kill-line
      bindkey -M menuselect '^[[Z' reverse-menu-complete

      setopt appendhistory
      setopt INC_APPEND_HISTORY  

      #unset PATH introduced by plugins
      ${lib.concatStrings (map (plugin: ''
        path[''${path[(I)$HOME/${zshcfg.pluginsDir}/${plugin.name}]}]=()
      '') zshcfg.plugins)}

      if [[ -f $HOME/.zshlocal ]]; then
        source $HOME/.zshlocal
      fi

    '';

    #if NIX_PROFILES env is absent, completions wouldn't work.
    #initExtraBeforeCompInit = ''
    #  # HACK #67
    #  # Fix broken autocompletion. See https://github.com/nix-community/home-manager/issues/2562.
    #  fpath+=("${config.home.profileDirectory}"/share/zsh/site-functions "${config.home.profileDirectory}"/share/zsh/$ZSH_VERSION/functions "${config.home.profileDirectory}"/share/zsh/vendor-completions)
    #'';

    #e.g. debug performance: zmodload zsh/zprof
    initExtraFirst = ''
      if [[ -f $HOME/.zshlocal-first ]]; then
        source $HOME/.zshlocal-first
      fi
    '';
  };
}

