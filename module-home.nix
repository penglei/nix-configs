{ config, pkgs, lib, ... }:
  let
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
      zoxide #autojump tool
      chezmoi fly
      starship #shell prompt
      #yabai #macOS twm(Tile Window Manager)
      #argocd
      gnupg pass gopass pwgen sops age   #secret security
      kustomize socat sshpass
      wget
      yq-go
      zellij
    ]);
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

  home.sessionVariables.EDITOR = "nvim";

  #It works only when managed shell is enabled.
  home.shellAliases = {};

  programs.direnv.nix-direnv.enable = true;
  programs.direnv.enable = true;

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


