{ lib, stdenvNoCC, fetchurl, ... }:

let
  version = "2025.03.27";

  srcDownloads = lib.listToAttrs [{
    name = "x86_64-linux";
    value = fetchurl {
      url =
        "https://github.com/zfl9/chinadns-ng/releases/download/${version}/chinadns-ng@x86_64-linux-musl@x86_64@fast+lto";
      sha256 = "sha256-Laji0EkNrt6HZcHwO+miiv5bkn9ZJncdlZfAXtueWl4=";
    };
  }];

in stdenvNoCC.mkDerivation {
  pname = "chinadns-ng-prebuilt";
  version = version;

  src = srcDownloads.${stdenvNoCC.system};

  ## Work around of the "unpacker appears to have produced no directories"
  ## case that happens when the archive doesn't have a subdirectory.
  setSourceRoot = "sourceRoot=`pwd`";

  unpackPhase = ''
    # echo "--------------------"
    # pwd
    # echo $src
    cp $src chinadns-ng
    # echo "--------------------"
  '';

  # buildInputs = [ bash ];
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin/
    install -m755 chinadns-ng -D $out/bin/

    runHook postInstall
  '';
  meta = {
    platforms = lib.platforms.unix;
    mainProgram = "chinadns-ng";
  };
}

