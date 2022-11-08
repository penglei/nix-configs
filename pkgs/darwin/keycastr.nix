{ fetchzip, stdenvNoCC }:

stdenvNoCC.mkDerivation rec {
  pname = "keycastr";
  version = "0.10.2";

  src = fetchzip {
    url =
      "https://github.com/keycastr/keycastr/releases/download/v${version}/KeyCastr.app.zip";
    sha256 = "sha256-KSFXxZLH0/GbItwoKoOF+GLVMgjQf10xtuWcWZLRNkI=";
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

