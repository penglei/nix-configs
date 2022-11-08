{ lib, stdenvNoCC, bash, fetchurl, }:

let
  version = "1.12.0-beta.13";

  srcDownloads = lib.listToAttrs [
    {
      name = "x86_64-linux";
      value = fetchurl {
        url =
          "https://github.com/SagerNet/sing-box/releases/download/v${version}/sing-box-${version}-linux-amd64.tar.gz";
        sha256 = "sha256-YWB1JRB3I6SaG7EP6oVBg7/PeiqLt3Shjpf6kxa0XmU=";
      };
    }
    {
      name = "aarch64-linux";
      value = fetchurl {
        url =
          "https://github.com/SagerNet/sing-box/releases/download/v${version}/sing-box-${version}-linux-arm64.tar.gz";
        sha256 = "";
      };
    }
  ];

in stdenvNoCC.mkDerivation {
  pname = "sing-box-prebuilt";
  version = version;

  src = srcDownloads.${stdenvNoCC.system};

  ## Work around of the "unpacker appears to have produced no directories"
  ## case that happens when the archive doesn't have a subdirectory.
  # setSourceRoot = "sourceRoot=`pwd`";

  buildInputs = [ bash ];
  installPhase = ''
    runHook preInstall

    install -m755 ./sing-box -D $out/bin/sing-box

    runHook postInstall
  '';
  meta = {
    platforms = lib.platforms.linux;
    mainProgram = "sing-box";
  };
}

