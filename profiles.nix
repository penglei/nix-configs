{ sops-nix, ... }:

{
  hm = rec {
    slim.modules = [
      ./hm-modules/default.nix
      ./hm-modules/zsh.nix
      ./hm-modules/fuzzyfilter.nix # fzf or skim
      ./hm-modules/starship.nix
    ];
    base.modules = slim.modules ++ [
      ./hm-modules/packages.nix
      ./hm-modules/zshvimode.nix
      ./hm-modules/git.nix
      ./hm-modules/tig.nix
      ./hm-modules/neovim.nix
      ./hm-modules/helix.nix
      ./hm-modules/misc.nix
    ];
    linux.modules = base.modules ++ [{
      # The compatibility between zsh-vi-mode and autopairs plugins is not good.
      zsh-vi-mode.enable = false;
    }];
    router.modules = slim.modules ++ [
      ./hm-modules/tig.nix
      ./hm-modules/neovim.nix
      { home.sessionVariables = { LC_TIME = "en_CN.UTF-8"; }; }
    ];
    darwin.modules = base.modules ++ [
      sops-nix.homeManagerModule
      ./secrets
      ./hm-modules/darwin/sops.nix
      ./hm-modules/darwin/launchd.nix
      ./hm-modules/alacritty.nix
      ./hm-modules/rio.nix
      ./hm-modules/darwin/shiori.nix
      ./hm-modules/darwin/passage.nix
      ./hm-modules/darwin/settings.nix
      ./hm-modules/darwin/keybindings.nix
      ./hm-modules/darwin/app-aliases.nix
      ./hm-modules/darwin/skhd.nix
      ./hm-modules/darwin/yabai.nix
      ./hm-modules/darwin/sketchybar.nix
      ./hm-modules/darwin/gpg.nix
      ./hm-modules/darwin/gpg-agent.nix
      ./hm-modules/darwin/ssh.nix
      ./hm-modules/darwin/rime-config.nix
      # ./hm-modules/darwin/texlive.nix
      ./hm-modules/darwin/fonts.nix
      ./hm-modules/darwin/chezscheme.nix
      ./hm-modules/darwin/snipaste.nix
      ./hm-modules/darwin/chezmoi.nix
      ./hm-modules/bat.nix
      ./hm-modules/yazi.nix # terminal file explorer
    ];
  };
}
