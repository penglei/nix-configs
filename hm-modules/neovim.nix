{ pkgs, ... }:

{
  imports = [ ];

  home.sessionVariables = rec {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Install the neovim binary via home.packages instead of programs.neovim.
  # programs.neovim auto-generates ~/.config/nvim/init.lua (a stub that only
  # disables providers), which clobbers the real init.lua managed in
  # nvim/v2-mini (symlinked into ~/.config/nvim). Using home.packages keeps hm
  # out of ~/.config/nvim entirely.
  home.packages = [ pkgs.neovim ];

  home.shellAliases = {
    vi = "nvim";
    vim = "nvim";
    vimdiff = "nvim -d";
  };
}
