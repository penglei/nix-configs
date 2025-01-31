{ pkgs, # pkgs used for standalone home-manager
system, home-manager, sops-nix, ... }:

rec {
  hm = rec {
    slim = {
      modules = [
        ./hm-modules/default.nix
        ./hm-modules/zsh.nix
        ./hm-modules/fzf.nix
        ./hm-modules/starship.nix
      ];
    };
    base = {
      modules = [
        ./hm-modules/default.nix
        ./hm-modules/packages.nix
        ./hm-modules/zsh.nix
        ./hm-modules/fzf.nix
        ./hm-modules/zshvimode.nix
        ./hm-modules/git.nix
        ./hm-modules/tig.nix
        ./hm-modules/starship.nix
        ./hm-modules/neovim.nix
        ./hm-modules/helix.nix
        ./hm-modules/misc.nix
      ];
    };
    linux.modules = base.modules ++ [{
      # The compatibility between zsh-vi-mode and autopairs plugins is not good.
      zsh-vi-mode.enable = false;

    }];
    darwin.modules = base.modules ++ [
      sops-nix.homeManagerModule
      ./hm-modules/darwin/launchd.nix
      ./hm-modules/alacritty.nix
      ./hm-modules/rio.nix
      ./hm-modules/darwin/shiori.nix
      ./hm-modules/darwin/sops.nix
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

  hm-creator = {
    standalone = username: {
      ${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = let isDarwin = pkgs.lib.hasSuffix "darwin" system;
        in [{ home.username = username; }] ++ (if isDarwin then
          hm.darwin.modules ++ [{
            # Home Manager needs a bit of information about you and the paths it should manage.
            home.homeDirectory = "/Users/${username}";
          }]
        else
          hm.linux.modules ++ [{ home.homeDirectory = "/home/${username}"; }]);
      };
    };
  };

  nixos-creator = { nixpkgs, system, hostname, username, overlays, modules
    , hm-modules ? hm.linux.modules, ... }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit nixpkgs username hostname; };
      modules = [
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        { nixpkgs.overlays = overlays; }
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username}.imports = hm-modules;
          # home-manager.extraSpecialArgs = { inherit username; };
        }
      ] ++ modules;
    };
}
