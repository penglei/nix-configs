{ lib, fetchurl, stdenvNoCC, undmg }:

stdenvNoCC.mkDerivation rec {
  pname = "koodo-reader";
  version = "1.7.2";

  src = fetchurl {
    url =
      "https://github.com/koodo-reader/koodo-reader/releases/download/v${version}/Koodo-Reader-${version}-arm64.dmg";
    sha256 = "";
  };

  sourceRoot = "Koodo Reader.app";

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    runHook preInstall
    appdir="Koodo Reader.app"
    mkdir -p "$out/Applications/$appdir"
    cp -R . "$out/Applications/$appdir"
    runHook postInstall
  '';
}

