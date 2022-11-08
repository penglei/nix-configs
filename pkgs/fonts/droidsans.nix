{ lib, stdenvNoCC, fetchgit }:

stdenvNoCC.mkDerivation rec {
  pname = "droidsans-fonts";
  version = "0.0.0";

  src = fetchgit {
    url = "https://github.com/grays/droid-fonts";
    rev = "42b78cf977bb2a2d5eaa5593a63e3d2ecf868f10";
    sha256 = "sha256-8IkkzIwMx60OrqR+5A6K/0n0vEHbdTUM65a0/aTIU3Y=";

    #postFetch = ''
    #  mkdir -p $out/share/fonts/truetype
    #  install *.ttf $out/share/fonts/truetype
    #'';
  };

  #nativeBuildInputs = [ unzip ];
  #unpackPhase = ''
  #  unzip $src
  #'';

  installPhase = ''
    runHook preInstall

    #find .

    mkdir -p $out/share/fonts/truetype
    install droid/*.ttf $out/share/fonts/truetype

    runHook postInstall
  '';
}
