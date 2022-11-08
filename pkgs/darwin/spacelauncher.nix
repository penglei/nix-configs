{ lib, fetchurl, stdenvNoCC, unzip }:

stdenvNoCC.mkDerivation rec {
  pname = "spacelauncher";
  version = "2.0.0-alpha-20230112-101";

  src = fetchurl {
    url =
      "https://spacelauncherapp.com/alpha/SpaceLauncher-2.0.0-alpha-20230112-(101).zip";
    sha256 = "sha256-wQW/iAQliWHCksiyQjoy3VEbYIul5vCWtxrq5rQuCvQ=";
  };

  nativeBuildInputs = [ unzip ];
  unpackCmd = "unzip $src";

  sourceRoot = ".";
  installPhase = ''
    runHook preInstall

    # echo -------------
    # echo source: $(ls)
    # echo out:$out
    # echo -------------
    # exit 1

    mkdir -p $out/Applications
    cp -r *.app $out/Applications

    runHook postInstall
  '';
}
