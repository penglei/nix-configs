{ lib, fetchzip, stdenvNoCC, undmg }:

stdenvNoCC.mkDerivation rec {
  pname = "netnewswire";
  version = "6.1.2";

  src = fetchzip {
    url =
      "https://github.com/Ranchero-Software/NetNewsWire/releases/download/mac-${version}/NetNewsWire${version}.zip";
    stripRoot = false;
    sha256 = "sha256-0+hFZd499LXc9Zlh/hbh/uNiF9llJUzaNIJ4Muqg9Pc=";
  };

  #sourceRoot = "."; # https://nixos.org/manual/nixpkgs/stable/#ssec-unpack-phase
  installPhase = ''
    runHook preInstall
    #find .
    #cat env-vars

    mkdir -p $out/Applications
    cp -r *.app $out/Applications
    runHook postInstall
  '';

  meta = with lib; {
    description = "It’s a free and open-source feed reader for macOS and iOS.";
    longDescription = ''
      It supports RSS, Atom, JSON Feed, and RSS-in-JSON formats."
    '';
    homepage = "https://netnewswire.com/";
    license = licenses.mit;
    platforms = platforms.darwin; # 10.15 is the minimum supported version.
  };
}
