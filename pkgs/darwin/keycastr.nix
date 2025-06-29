{ fetchzip, stdenvNoCC }:

stdenvNoCC.mkDerivation rec {
  pname = "keycastr";
  version = "0.10.3";

  src = fetchzip {
    url = "https://github.com/keycastr/keycastr/releases/download/v${version}/KeyCastr.app.zip";
    sha256 = "sha256-w0AmPrv0G2IrrfABjmSKwRCCJsMxImoGwKTGMEdemDU=";
    stripRoot = false;
    name = "${pname}-${version}.app.zip";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
    runHook postInstall
  '';
}
