{ fetchzip, stdenvNoCC }:

stdenvNoCC.mkDerivation {
  pname = "tart";
  version = "2.41.1";

  src = fetchzip {
    url = "https://github.com/openai/tart/releases/download/2.41.1/tart.tar.gz";
    sha256 = "sha256-5NVUIhtOy6mhP21fuL+L16bcNfbs+Fmn+eItgMrXR18=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
    ln -s Applications/tart.app/Contents/MacOS $out/bin
    runHook postInstall
  '';
}
