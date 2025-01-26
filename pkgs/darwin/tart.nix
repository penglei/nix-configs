{ fetchzip, stdenvNoCC }:

stdenvNoCC.mkDerivation {
  pname = "tart";
  version = "2.24.0";

  src = fetchzip {
    url =
      "https://github.com/cirruslabs/tart/releases/download/2.24.0/tart.tar.gz";
    sha256 = "sha256-qwROunVH21J5pXLAuaQLA9f75DCFPOICQKXLQIuNGD8=";
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

