{ lib, fetchurl, stdenvNoCC, undmg }:

stdenvNoCC.mkDerivation rec {
  pname = "rectangle";
  version = "0.63";

  src = fetchurl {
    url =
      "https://github.com/rxhanson/Rectangle/releases/download/v${version}/Rectangle${version}.dmg";
    sha256 = "sha256-xgO9fqf8PX0SwEsMVef3pBiaLblTgo9ZNrqHUn0+JIg=";
  };

  sourceRoot = "Rectangle.app";

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    mkdir -p $out/Applications/Rectangle.app
    cp -R . $out/Applications/Rectangle.app
  '';

  meta = with lib; {
    description =
      "Move and resize windows in macOS using keyboard shortcuts or snap areas";
    homepage = "https://rectangleapp.com/";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = platforms.darwin;
    maintainers = with maintainers; [ Enzime ];
    license = licenses.mit;
  };
}
