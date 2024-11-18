{ pkgs, config, ... }:

{
  home.packages = with pkgs;
    [
      fortune
      coreutils-full
      getopt
      gnused
      gnugrep
      gnutar
      pstree
      tree
      watch
      findutils
      help2man
      ascii
      libiconv
      gnumake
      m4
      libtool
      autoconf
      automake
      cmake
      ninja
      #gnupg
      openssh
      openssl # openssl and openssh should be paired, don't use macOS default
      htop
      rsync
      wget
      curl
      xz
      zstd
      rhash
      ripgrep
      fd
      jq
      yq-go
      fx
      bat
      git-lfs
      tig
      tmux
      fzf
      asciinema # terminal recording
      socat
      sops
      age
      diceware
      pwgen
      ssh-tools
      hyperfine # performance test
      #ghostscript
      hexyl

      fastfetch # neofetch screenfetch
      #rar
      #! rar is an unfree software, but we can't set allowunfree at this moment(2022-11-08)
      #! if we enable it, tedious commond `NIXPKGS_ALLOW_UNFREE=1 home-manager switch --impure`
      #! must be executed to switch home configuration.

      # wireguard-tools

      difftastic

      #emacs-nox
      helix # modern editor

      #tree-sitter #generic ast parser
      # koka

      watchexec

      mynixcleaner

    ] ++ lib.optionals stdenvNoCC.isDarwin [
      bash
      git-cliff
      gnupg # full with gui
      passage
      yubikey-manager
      yubico-piv-tool
      age-plugin-yubikey
      yabai
      skhd
      keycastr
      sketchybar
      kitty
      utm
      graphviz
      presentation
      #jetbrains.pycharm-community
      netnewswire
      rectangle
      preview_open
      # isabelle_app
      koodo-reader
      #adobe-reader
      #bitwarden-desktop
      #rar #NIXPKGS_ALLOW_UNFREE=1 nix profile install nixpkgs#rar --impure
      p7zip
      libarchive # for decompress .pkg installer
      #duti # set default applications in alfred
      #chez-racket
      alttab
      shiori # web bookmarks

      trash-cli

      go_1_22
      #gotools #these plugins are managed by neovim ray-x/go.vim plugin.
      nodejs_latest

      typos # source code typo checking

      k9s
      kustomize
      kubectl
      krew
      kubectl-kubectx
      kubectl-kubecm
      kubectl-nodeshell

      sqlite.out # for neovim telescope plugin

      ##editor (lsp, dap, linter, formatter)
      nixfmt-classic # nixfmt was renamed to nixfmt-classic. The nixfmt attribute may be used for the new RFC 166-style formatter in the future, which is currently available as nixfmt-rfc-style
      nil-language-server

      yaml-language-server
      nodePackages.bash-language-server
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted # HTML/CSS/JSON/ESLint language servers extracted from
      nodePackages.prettier
      prettierd
      yamlfmt
      shfmt

      #pbls requirements
      protobuf
      buf # buf contains format tool

      #lisp
      parinfer-rust # vim plugin for lisp brackets

      #python
      python3 # (python3.withPackages (ps: [ ps.numpy ps.pygments]))
      python3Packages.python-lsp-server
      isort
      black

      lua5_1
      luarocks
      stylua
      lua-language-server

      #starlark
      # starlark-rust
      buildifier

      typst
      typstyle
      typst-lsp

    ] ++ lib.optionals stdenvNoCC.isLinux [
      #binutils #`ld` is not recommended installing globally.

      #(gnupg.override {
      #  enableMinimal = true;
      #  guiSupport = false;
      #})
      (gnupg.overrideAttrs (finalAttrs: previousAttrs: {
        postInstall = ''
          # add gpg2 symlink to make sure git does not break when signing commits
          ln -s $out/bin/gpg $out/bin/gpg2

          # Make libexec tools available in PATH
          for f in $out/libexec/; do
            if [[ "$(basename $f)" == "gpg-wks-client" ]]; then continue; fi
            ln -s $f $out/bin/$(basename $f)
          done
        '';
      }))
    ];
}
