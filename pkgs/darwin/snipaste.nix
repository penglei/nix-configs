{ lib, fetchurl, stdenvNoCC, undmg }:

stdenvNoCC.mkDerivation rec {
  pname = "snipaste";
  version = "2.10.4";

  # https://docs.snipaste.com/zh-cn/download
  src = fetchurl {
    url = "https://download.snipaste.com/archives/Snipaste-${version}.dmg";
    sha256 = "sha256-3sZjWlnMf90KvvaDdNT9ZGUe9/m304ybXKPJRHHLIl8=";
  };

  sourceRoot = "Snipaste.app";

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    mkdir -p $out/Applications/Snipaste.app
    cp -R . $out/Applications/Snipaste.app
  '';

  meta = with lib; {
    description = "Screenshot tools";
    homepage = "https://www.snipaste.com/";
    platforms = platforms.darwin;
    license = licenses.mit;
  };
}
