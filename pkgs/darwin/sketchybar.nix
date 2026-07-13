{
  lib,
  stdenv,
  fetchFromGitHub,
  apple-sdk_15,
}:

let
  inherit (stdenv.hostPlatform) system;
  target =
    {
      "aarch64-darwin" = "arm64";
      "x86_64-darwin" = "x86";
    }
    .${system} or (throw "Unsupported system: ${system}");

in
stdenv.mkDerivation {
  pname = "sketchybar";
  version = "master";

  src = fetchFromGitHub {
    owner = "FelixKratz";
    repo = "SketchyBar";
    rev = "6284ee816601486ace33ca48a0271832eec6de35";
    sha256 = "sha256-5tyc/yYzdV/3JTtujuj7le/14XkC7TlN/nZg7tOZsNg=";
  };

  buildInputs = [
    apple-sdk_15
  ];

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
