{ lib, stdenvNoCC, bash, fetchurl, }:

let
  version = "1.3.2";

  srcDownloads = lib.listToAttrs [
    {
      name = "x86_64-linux";
      value = fetchurl {
        url =
          "https://github.com/shadowsocks/v2ray-plugin/releases/download/v${version}/v2ray-plugin-linux-amd64-v${version}.tar.gz";
        sha256 = "sha256-tXhRQjW5iyMPiBqioBpydyBfhRNbwJ/Dgy5fOZPuVBo=";
      };
    }
    {
      name = "aarch64-linux";
      value = fetchurl {
        url =
          "https://github.com/shadowsocks/v2ray-plugin/releases/download/v${version}/v2ray-plugin-linux-arm64-v${version}.tar.gz";
        sha256 = "sha256-7wdGfNvSSc3sUXgJ0oGtqRxbRkDn8AOjJNFFzh5m/sM=";
      };
    }
  ];

in stdenvNoCC.mkDerivation {
  pname = "v2ray-plugin";
  version = version;

  src = srcDownloads.${stdenvNoCC.system};

  # Work around the "unpacker appears to have produced no directories"
  # case that happens when the archive doesn't have a subdirectory.
  setSourceRoot = "sourceRoot=`pwd`";

  buildInputs = [ bash ];
  installPhase = ''
    runHook preInstall

    install -m755 ./v2ray-plugin_* -D $out/bin/v2ray-plugin

    runHook postInstall
  '';
  meta = with lib; { platforms = platforms.linux; };
}

