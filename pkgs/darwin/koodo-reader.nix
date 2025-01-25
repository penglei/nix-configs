{ fetchurl, stdenvNoCC, undmg }:

stdenvNoCC.mkDerivation rec {
  pname = "koodo-reader";
  version = "1.7.4";

  src = fetchurl {
    url =
      "https://github.com/koodo-reader/koodo-reader/releases/download/v${version}/Koodo-Reader-${version}-arm64.dmg";
    sha256 = "sha256-3vgRyOR3vaeIrhA2o5XaSZVW7L0u5iQknZXIl1du/EE=";
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

