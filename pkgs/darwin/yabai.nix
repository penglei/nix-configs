{ lib, stdenvNoCC, bash, fetchurl, ... }:

let
  pname = "yabai";
  version = "7.1.15";
in {
  aarch64-darwin = stdenvNoCC.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url =
        "https://github.com/koekeishiya/yabai/releases/download/v${version}/yabai-v${version}.tar.gz";
      sha256 = "sha256-hlAJqlwcUmNbW2gFY0zldAgM1YEQHepO8SgHOcNLjwI=";
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
