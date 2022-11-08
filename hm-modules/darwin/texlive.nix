{ config, pkgs, ... }:
let
  tex = (pkgs.texlive.combine {
    inherit (pkgs.texlive)
      scheme-full dvisvgm dvipng # for preview and export as html
      wrapfig amsmath ulem hyperref capt-of textpos changepage minted fvextra;
    #(setq org-latex-compiler "lualatex")
    #(setq org-preview-latex-default-process 'dvisvgm)
  });
in { # home-manager
  home.packages = with pkgs; [ tex ];
}
