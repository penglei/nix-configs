

{ lib, stdenvNoCC, fetchgit }:

stdenvNoCC.mkDerivation rec {
  pname = "sfmono"; # https://developer.apple.com/fonts/
  version = "2018";

  src = fetchgit {
    url = "https://github.com/supercomputra/SF-Mono-Font.git";
    rev = "1409ae79074d204c284507fef9e479248d5367c1";
    sha256 = "sha256-3wG3M4Qep7MYjktzX9u8d0iDWa17FSXYnObSoTG2I/o=";
  };

  installPhase = ''
    runHook preInstall

    #find .

    mkdir -p $out/share/fonts/opentype
    install *.otf $out/share/fonts/opentype

    runHook postInstall
  '';
}
