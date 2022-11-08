{ lib, fetchurl, stdenvNoCC, undmg, p7zip, libarchive, unzip }:

stdenvNoCC.mkDerivation rec {
  pname = "adobe-reader";
  version = "2200320314";

  src = fetchurl {
    url =
      "https://ardownload2.adobe.com/pub/adobe/reader/mac/AcrobatDC/${version}/AcroRdrDC_${version}_MUI.dmg";
    sha256 = "sha256-ouy241PNFLXGBrS1yEfRdZA+c6/cXcZ0xJy06Pmreek=";
  };

  nativeBuildInputs = [ undmg p7zip libarchive unzip ];

  decompressScript = ../../scripts/adobe-pdf-reader-decompress;

  unpackPhase = ''
    undmg $src
    7z x AcroRdrDC_2200320314_MUI.pkg
    cd application.pkg
    bsdtar -xf Payload
    cd ..
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    mv application.pkg/"Adobe Acrobat Reader.app" "$out/Applications"

    (cd $out/Applications/*.app/Contents && bash ${decompressScript})

    runHook postInstall
  '';
}

