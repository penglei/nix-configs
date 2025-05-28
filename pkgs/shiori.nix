{ lib, stdenv, ... }:

stdenv.mkDerivation rec {
  pname = "shiori-dev";
  version = "local";

  doCheck = false;
  dontUnpack = true;

  src = ../stuff/pre-builtis/darwin/arm64/shiori;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -Dm755 ${src} $out/bin/shiori
    runHook postInstall
  '';

  meta = with lib; {
    description = "Simple bookmark manager built with Go";
    mainProgram = "shiori";
    homepage = "https://github.com/go-shiori/shiori";
    license = licenses.mit;
    platforms = platforms.darwin;
  };
}

