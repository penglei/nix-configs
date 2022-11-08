{ lib, stdenvNoCC, bash, fetchurl, fetchzip }:

let

  version = "1.6.1";

  srcDownloads = lib.listToAttrs [
    {
      name = "aarch64-darwin";
      value = fetchzip {
        url =
          "https://downloads.mongodb.com/compass/mongosh-${version}-darwin-arm64.zip";
        sha256 = "sha256-BraBqclwpzYXbt9WyJeLaJX/lshpIkvuZRwGHaRivvc=";
      };
    }

    {
      name = "x86_64-darwin";
      value = fetchzip {
        url =
          "https://downloads.mongodb.com/compass/mongosh-${version}-darwin-x64.zip";
        sha256 = "";
      };
    }

    {
      name = "aarch64-linux";
      value = fetchurl {
        url =
          "https://downloads.mongodb.com/compass/mongosh-${version}-linux-arm64.tgz";
        sha256 = "sha256-48DaHH/79+hdqJrCuQNjUbcCw0yl3OGbJha6ikboOf4=";
      };
    }

    {
      name = "x86_64-linux";
      value = fetchurl {
        url =
          "https://downloads.mongodb.com/compass/mongosh-${version}-linux-x64.tgz";
        sha256 = "";
      };
    }
  ];

in stdenvNoCC.mkDerivation {
  pname = "mongosh-prebuilt";
  version = version;

  src = srcDownloads.${stdenvNoCC.system};

  # Work around the "unpacker appears to have produced no directories"
  # case that happens when the archive doesn't have a subdirectory.
  #setSourceRoot = "sourceRoot=`pwd`";

  buildInputs = [ bash ];
  installPhase = ''
    runHook preInstall

    install -m755 ./bin/* -Dt $out/bin
    install -m0644 mongosh.1.gz -Dt $out/share/doc

    runHook postInstall
  '';
  meta = with lib; { platforms = platforms.darwin; };
}
