{ pkgs, ... }:
with pkgs;

(callPackage ./officials.nix { })
// {

  bookmarks = fetchFromGitHub {
    owner = "dedukun";
    repo = "bookmarks.yazi";
    rev = "fbb7c00b6f887d5c0d78367bd4763ea8dff53459";
    hash = "sha256-Ry3V29T7lij5JR68gTINXtOEgbrYPwd5zQDEa2kfpTA=";

  };

  fg = fetchFromGitHub {
    owner = "lpnh";
    repo = "fg.yazi";
    rev = "6d5e4693e486c564f57491cb9afdf7bf813ae874";
    hash = "sha256-M4idc573oSlX9XMI4Hfzo7gOMFDV91yKOvYmm5rRdio=";
  };
  #more:
  #https://github.com/h-hg/yamb.yazi
}
