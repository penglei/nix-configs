{ lib, bash, stdenvNoCC, fetchurl }:

let
  version = "0.5.0";
  srcDownloads = lib.listToAttrs [{
    name = "aarch64-darwin";
    value = fetchurl {
      url =
        "https://github.com/typst/typst/releases/download/v${version}/typst-aarch64-apple-darwin.tar.xz";
      sha256 = "sha256-y94+u1SBw08FESLMGhzQVrXE+WvbPXATxU7Hrb5LEzQ=";
    };
  }];

in stdenvNoCC.mkDerivation {
  pname = "typst-prebuilt";
  version = version;

  src = srcDownloads.${stdenvNoCC.system};

  #setSourceRoot = "sourceRoot=`pwd`";

  buildInputs = [ bash ];

  installPhase = ''
    runHook preInstall
    install -m755 ./typst -Dt $out/bin
    runHook postInstall
  '';

  meta = with lib; {
    description =
      "A new markup-based typesetting system that is powerful and easy to learn";
    homepage = "https://typst.app";
    changelog = "https://github.com/typst/typst/releases/tag/v${version}";
    license = licenses.asl20;
    platforms = platforms.darwin;
  };
}
