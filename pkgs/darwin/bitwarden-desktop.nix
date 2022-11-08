{ lib, fetchurl, stdenvNoCC, undmg }:

#nix store add-file ./xxx.dmg
#nix hash file ./xxx.dmg
stdenvNoCC.mkDerivation rec {
  pname = "bitwarden-desktop";
  version = "2023.1.0";

  src = fetchurl {
    url =
      "https://github.com/bitwarden/clients/releases/download/desktop-v2023.1.0/Bitwarden-2023.1.0-universal.dmg";
    sha256 = "sha256-hWqbvE71h9Y1tgi6zJX5jmv7aMycC1pLcqP6vOUGopc=";
  };

  sourceRoot = "Bitwarden.app";

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    appdir="Bitwarden.app"
    mkdir -p "$out/Applications/$appdir"
    cp -R . "$out/Applications/$appdir"
  '';
}

