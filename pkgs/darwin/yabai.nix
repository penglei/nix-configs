{ lib, stdenvNoCC, bash, fetchurl, ... }:

let
  pname = "yabai";
  version = "7.1.6";
in {
  aarch64-darwin = stdenvNoCC.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url =
        "https://github.com/koekeishiya/yabai/releases/download/v${version}/yabai-v${version}.tar.gz";
      sha256 = "sha256-HSuZ9TwkBWgUy0kSzrqJ6lTQlaMtq7EJZ3FlDFn231w=";
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
