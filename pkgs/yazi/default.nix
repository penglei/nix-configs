{ pkgs, ... }:
with pkgs;

(callPackage ./officials.nix { }) // {

  bookmarks = fetchFromGitHub {
    owner = "dedukun";
    repo = "bookmarks.yazi";
    rev = "20ece7e1ef3c8180f199cc311f187b662662bc87";
    hash = "sha256-CpoHpYAeMuSn5Sfaq30vzTj/ukrUjtXI0zZioJLnWqw=";
  };
}
