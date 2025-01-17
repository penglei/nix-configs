{ lib, stdenvNoCC, bash, fetchurl, ... }:

let
  pname = "yabai";
  version = "7.1.5";
in {
  aarch64-darwin = stdenvNoCC.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url =
        "https://github.com/koekeishiya/yabai/releases/download/v${version}/yabai-v${version}.tar.gz";
      sha256 = "sha256-U+hzkxhJTBDDWF4e4inbWz7laCiV69lHCGlQt50WIhQ=";
    };

    buildInputs = [ bash ];
    installPhase = ''
      runHook preInstall

      install -m755 ./bin/* -Dt $out/bin

      runHook postInstall
    '';
  };

}.${stdenvNoCC.hostPlatform.system} or (throw
  "Unsupported platform ${stdenvNoCC.hostPlatform.system}")
