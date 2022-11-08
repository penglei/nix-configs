{ lib, fetchzip, stdenvNoCC }:

stdenvNoCC.mkDerivation rec {
  pname = "alttab";
  version = "7.19.1";

  src = fetchzip {
    url =
      "https://github.com/lwouis/alt-tab-macos/releases/download/v${version}/AltTab-${version}.zip";
    sha256 = "sha256-yd0wmk98wauzYMJOIMbMLsNVx/rJlhJ3QxiY7lTK0SI=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
    runHook postInstall
  '';

}
