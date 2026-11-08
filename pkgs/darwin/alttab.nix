{
  lib,
  fetchzip,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "alttab";
  version = "11.10.1";

  src = fetchzip {
    url = "https://github.com/lwouis/alt-tab-macos/releases/download/v${version}/AltTab-${version}.zip";
    sha256 = "sha256-2gXYMXz7RmSr4ZIZGHCT+L98jbAt8Ou8pCzxqH8xqEQ=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
    runHook postInstall
  '';

}
