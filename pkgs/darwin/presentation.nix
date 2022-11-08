{ lib, stdenv, fetchurl, libarchive, p7zip }:

stdenv.mkDerivation rec {
  pname = "presentation";
  version = "3.3.0";

  src = fetchurl {
    url =
      "http://iihm.imag.fr/blanch/software/osx-presentation/releases/osx-presentation-${version}.pkg";
    sha256 = "sha256-7BaP5OoyaFc5IHkrcMwvqnZmjgyhHBgO1AaJlPyI/2U=";
  };

  dontBuild = true;
  nativeBuildInputs = [ libarchive p7zip ];

  unpackPhase = ''
    7z x $src
    bsdtar -xf Payload~
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -R Présentation.app $out/Applications/
    runHook postInstall
  '';

  meta = with lib; {
    description = "A presentation tool for pdf slides for Mac OS X";
    homepage = "http://iihm.imag.fr/blanch/software/osx-presentation/";
    license = licenses.gpl3;
    platforms = platforms.darwin;
  };
}

