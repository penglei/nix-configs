{ pkgs, ... }: {
  # **************************installation****************************#
  # bootstrap tips:                                                   #
  #  first run `nix shell home-manager#home-manager`,                 #
  #  then run `home-manager switch --flake .#penglei`                 #
  #                                                                   #
  #  legacy solution.  `nix-shell -p 'home-manager'`                  #
  # let Home Manager manage itself.                                   #
  programs.home-manager.enable = true;
  #####################################################################

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  xdg.enable = true;

  nix = { settings = { use-xdg-base-directories = true; }; };

  programs = {
    command-not-found.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    zoxide.enable = true;
  };
  home.packages = [ pkgs.mynixcleaner ];
}

