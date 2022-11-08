{ fetchurl, stdenvNoCC, undmg }:

stdenvNoCC.mkDerivation {
  pname = "keycodes";
  version = "221";

  src = fetchurl {
    url = "https://manytricks.com/download/_do_not_hotlink_/keycodes221.dmg";
    sha256 = "sha256-olkBADBFq5B5r52R0llmAgCevnl1BRmt12Zom05cDVQ=";
  };

  nativeBuildInputs = [ undmg ];

  sourceRoot = "Key Codes.app";

  installPhase = ''
    runHook preInstall
    appdir="Key Codes.app"
    mkdir -p "$out/Applications/$appdir"
    cp -R . "$out/Applications/$appdir"
    runHook postInstall
  '';
}

#alternatives: keystro
