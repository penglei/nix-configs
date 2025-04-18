{ lib, bash, stdenvNoCC, fetchurl }:

let
  version = "1.0.8";
  srcDownloads = lib.listToAttrs [{
    name = "aarch64-darwin";
    value = fetchurl {
      url =
        "https://github.com/rcorre/pbls/releases/download/${version}/pbls-${version}-macos.tar.xz";
      sha256 = "sha256-Uhg8Fkhsl/WD6AD2w9MX/Y1mJhCXLr5wusYm5O/yPss=";
    };
  }];

in stdenvNoCC.mkDerivation {
  pname = "pbls-prebuilt";
  version = version;

  src = srcDownloads.${stdenvNoCC.system};

  sourceRoot = "."; # equal to: setSourceRoot = "sourceRoot=`pwd`";

  buildInputs = [ bash ];

  installPhase = ''
    runHook preInstall
    install -m755 ./pbls -Dt $out/bin
    runHook postInstall
  '';
}
