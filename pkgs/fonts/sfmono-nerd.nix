{ lib, stdenvNoCC, fetchgit }:

stdenvNoCC.mkDerivation rec {
  pname = "sfmono-nerd"; # https://developer.apple.com/fonts/
  version = "v18.0d1e1.0";

  src = fetchgit {
    url = "https://github.com/epk/SF-Mono-Nerd-Font";
    rev = "v18.0d1e1.0";
    sha256 = "sha256-f5A/vTKCUxdMhCqv0/ikF46tRrx5yZfIkvfExb3/XEQ=";
  };

  installPhase = ''
    runHook preInstall

    #find .

    mkdir -p $out/share/fonts/opentype
    install *.otf $out/share/fonts/opentype

    runHook postInstall
  '';
}

