{ pkgs, ... }:
with pkgs;

(callPackage ./officials.nix { }) // {

  bookmarks = fetchFromGitHub {
    owner = "dedukun";
    repo = "bookmarks.yazi";
    rev = "20ece7e1ef3c8180f199cc311f187b662662bc87";
    hash = "sha256-CpoHpYAeMuSn5Sfaq30vzTj/ukrUjtXI0zZioJLnWqw=";
  };

  fg = fetchFromGitHub {
    owner = "lpnh";
    repo = "fg.yazi";
    rev = "9bba7430dbcd30995deea600499b069fe6067a3e";
    hash = "sha256-3VjTL/q4gSDIHyPXwUIQA/26bbhWya+01EZbxSKzzQo=";
  };
  #more:
  #https://github.com/h-hg/yamb.yazi
}
