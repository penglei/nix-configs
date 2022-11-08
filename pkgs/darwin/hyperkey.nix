{ fetchurl, stdenvNoCC, undmg }:

#Manually add hyperkey to the store in advance.
#❯ nix hash file Hyperkey0.45.dmg
#sha256-koZL9F0jzqCmDBg1dHlvrZK0I+RAif7ABb2Bay1hQdM=
#❯ nix store add-file Hyperkey0.45.dmg
#/nix/store/s2qrvrp9ns6kf5x9sh31pk4j19ygydkz-hyperkey-0.45
#N.B. Don't specify custom name when adding file to store, or nix will still download it.
#However, we can specify the same name that adding to store for fetcher, which can prevent downloading.

stdenvNoCC.mkDerivation rec {
  pname = "hyperkey";
  version = "0.45";

  src = fetchurl {
    url = "https://hyperkey.app/downloads/Hyperkey0.45.dmg";
    sha256 = "sha256-koZL9F0jzqCmDBg1dHlvrZK0I+RAif7ABb2Bay1hQdM=";
    name = "${pname}-${version}.dmg";
  };

  nativeBuildInputs = [ undmg ];

  sourceRoot = "Hyperkey.app";

  installPhase = ''
    runHook preInstall
    appdir="Hyperkey.app"
    mkdir -p "$out/Applications/$appdir"
    cp -R . "$out/Applications/$appdir"
    runHook postInstall
  '';
}

