{ lib, stdenvNoCC, fetchurl, bash, ... }:

stdenvNoCC.mkDerivation rec {
  pname = "shiori";
  version = "1.7.4";

  src = fetchurl {
    url =
      "https://github.com/go-shiori/shiori/releases/download/v${version}/shiori_Darwin_aarch64_${version}.tar.gz";
    sha256 = "sha256-4wj0GVJ7256Sljfh0JTpEEt+MunNpF5cXS0WCJniq2I=";
  };

  # Work around the "unpacker appears to have produced no directories"
  # case that happens when the archive doesn't have a subdirectory.
  setSourceRoot = "sourceRoot=`pwd`";

  buildInputs = [ bash ];
  installPhase = ''
    runHook preInstall

    install -m755 ./shiori -D $out/bin/shiori

    runHook postInstall
  '';
  meta = with lib; { platforms = platforms.darwin; };
}

