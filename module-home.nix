{ config, pkgs, lib, ... }:
  let
    lang = "en_US.UTF-8";
    packages = (with pkgs; [
      fortune coreutils-full gnugrep openssh htop rsync ripgrep fd pstree jq tree watch help2man findutils
      m4 libtool autoconf automake cmake ninja
      nixfmt git-lfs tig vim neovim tmux fzf corkscrew

      #rar #! this is unfree software, but we can't set allowunfree at this moment(2022-11-08)
           #! enable it we must run `NIXPKGS_ALLOW_UNFREE=1 home-manager switch --impure` to switch HOME

      tree-sitter #generic ast parser
      deno
      #clang_13 clang-tools_13 #clang-wrapper
      #rustc cargo
      koka
      go protobuf
      ocaml opam ocamlPackages.sexp
      bear #Tool that generates a compilation database for clang tooling
      #nickel cue jsonnet dhall dhall-json
      ghostscript #mypython #python3
      kubectl krew
      #brotli #google compression tools
      #zoxide #autojump tool
      fly
      #starship #shell prompt
      #yabai #macOS twm(Tile Window Manager)
      #argocd
      #chezmoi 
      pass gopass pwgen sops age   #secret security
      kustomize socat sshpass
      wget
      yq-go fx
      zellij
    ] ++ (import ./kubectl-plugins.nix {inherit pkgs stdenv;}));

    zshcfg = import ./zshcfg.nix {inherit config lib;};
    gitaliases = import ./git-aliases.nix;

  in {

  # **************************installation**********************************#
  # bootstrap tips:                                                         #
  #  first run `nix shell home-manager#home-manager`,                       #
  #  then run `home-manager switch --flake .#penglei`                       #
  #                                                                         #
  #   legacy solution.  `nix-shell -p 'home-manager'`                       #
  # let Home Manager manage itself.                                         #
  programs.home-manager.enable = true;                                      #
  ###########################################################################

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "penglei";
  home.homeDirectory = "/Users/penglei";

  home.packages = packages;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  #It works only when managed shell is enabled.
  home.shellAliases = {
    ll = "ls -l";
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    k = "kubectl";
  } // gitaliases;

  programs.direnv.nix-direnv.enable = true;
  programs.direnv.enable = true;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    autocd = true;
    defaultKeymap = "emacs";
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
    ];
    envExtra = ''
      export LANG="${lang}";
    '';
    initExtra = ''
      #unset PATH introduced by plugins
      ${lib.concatStrings (map (plugin: ''
        path[''${path[(I)$HOME/${zshcfg.pluginsDir}/${plugin.name}]}]=()
      '') zshcfg.plugins)}

      export GPG_TTY=$(tty)
      export SSH_AUTH_SOCK="$(gpgconf --homedir ${config.programs.gpg.homedir} --list-dirs agent-ssh-socket)"
    '';

    #debug performance
    #initExtraFirst = ''
    #  zmodload zsh/zprof 
    #'';
  };

  programs.zoxide.enable = true;

  programs.fzf = {
    enable = true;
    defaultOptions = [ "--height 90%" "--reverse" "--bind up:preview-up,down:preview-down" ];
    historyWidgetOptions = [ "--sort" "--exact" ];
    changeDirWidgetOptions = [ "--preview 'tree -C {} | head -200'" ];
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = lib.concatStrings [
        "$username$directory$git_branch$git_state$git_status$kubernetes$time$status$line_break$character"
      ];
      username = {
        disabled = false;
        #show_always = true;
        style_user = "white bold";
        style_root = "black bold";
        format = "[ $user]($style) ";
      };
      directory = {
        truncation_length = 7;
        truncate_to_repo = false;
        truncation_symbol = "… ";
        format = "[$path]($style) ";
        style = "green";
      };
      kubernetes = {
        disabled = false;
        symbol = "☸";
        format = "[$context(\\($namespace\\))]($style) ";
        style = "blue";
      };
      git_status = {
        disabled = false;
        untracked = "";
        format = "([\\[$conflicted$deleted$renamed$modified$staged$behind\\]]($style) )";
        modified = "*";
      };
      status = {
        format = "[\\($symbol$common_meaning$signal_name$maybe_int\\)]($style) ";
        disabled = false;
        style = "red";
      };
      time = {
        disabled = false;
        #symbol = "";
        format = "[\\[$time\\]]($style)";
        time_format = "%m-%d %T";
        utc_time_offset = "+8";
        style = "yellow";
      };
      character = {
        success_symbol = "[λ](grey)";
        error_symbol = "[λ](bold red)";
      };
      scan_timeout = 10;
    };
  };

  home.file."${config.programs.gpg.homedir}/gpg-agent.conf".text = ''enable-ssh-support'';
  programs.gpg = {
    enable = true;
    settings = {
      # https://gist.github.com/graffen/37eaa2332ee7e584bfda
      "no-emit-version" = true;
      "no-comments" = true;
      "use-agent" = true;
      "with-fingerprint" = true;
      "with-keygrip" = true;
      #"show-unusable-subkeys" = true;
      "keyid-format" = "long";
      
      "list-options" = "show-uid-validity";

      # list of personal digest preferences. When multiple digests are supported by
      # all recipients, choose the strongest one
      "personal-cipher-preferences"  = "AES256 TWOFISH AES192 AES";
      
      # list of personal digest preferences. When multiple ciphers are supported by
      # all recipients, choose the strongest one
      "personal-digest-preferences" = "SHA512 SHA384 SHA256 SHA224";
      
      # message digest algorithm used when signing a key
      "cert-digest-algo" = "SHA512";
      
      # This preference list is used for new keys and becomes the default for "setpref" in the edit menu
      "default-preference-list" = "SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed";
    };
  };

  programs.git = {
    enable = true;
    userEmail = "penglei@ybyte.org";
    userName = "penglei";
    extraConfig = {
      pager.branch = false;
    };
    aliases = {
      track = "checkout --track";
    };
  };
}

