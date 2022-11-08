{ lib, stdenv, fetchFromGitHub, Carbon, Cocoa, CoreWLAN, DisplayServices
, SkyLight, MediaRemote }:

let
  inherit (stdenv.hostPlatform) system;
  target = {
    "aarch64-darwin" = "arm64";
    "x86_64-darwin" = "x86";
  }.${system} or (throw "Unsupported system: ${system}");

in stdenv.mkDerivation rec {
  pname = "sketchybar";
  version = "master"; # >=2.19.4

  src = fetchFromGitHub {
    owner = "FelixKratz";
    repo = "SketchyBar";
    rev = "1fbf8559302f4e69e015f08a76e05ea84a93cef8";
    sha256 = "sha256-6MqTyCqFv5suQgQ5a9t1mDA2njjFFgk67Kp7xO5OXoA=";
  };

  buildInputs = [ Carbon Cocoa CoreWLAN DisplayServices SkyLight MediaRemote ];

  makeFlags = [ target ];

  installPhase = ''
    mkdir -p $out/bin
    cp ./bin/sketchybar $out/bin/sketchybar
  '';

  meta = with lib; {
    description = "A highly customizable macOS status bar replacement";
    homepage = "https://github.com/FelixKratz/SketchyBar";
    platforms = platforms.darwin;
    maintainers = [ maintainers.azuwis ];
    license = licenses.gpl3;
  };
}
