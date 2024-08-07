{ config, lib, pkgs, wayland, ... }:

{
  imports = [
    #./language-server.nix
    #./plugins.nix
  ];

  home.sessionVariables = rec {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    ## Clipboard support
    #extraPackages = lib.mkIf pkgs.stdenvNoCC.isLinux (with pkgs;
    #  lib.optional wayland wl-clipboard
    #  ++ lib.optional (!wayland) xclip);

    #extraConfig =
    #  let
    #    inherit (import ./util.nix) mkLuaFile;

    #    bindings = pkgs.substituteAll {
    #      src = ./scripts/bindings.lua;
    #      findAndReplace = ./scripts/find-and-replace.lua;
    #    };

    #    autocmds = pkgs.substituteAll {
    #      src = ./scripts/autocmds.lua;
    #      git = "${pkgs.git}/bin/git";
    #    };
    #  in
    #  (mkLuaFile ./scripts/options.lua) +
    #  (mkLuaFile ./scripts/options.lua) +
    #  (mkLuaFile bindings) +
    #  (mkLuaFile autocmds);
  };
}

