{ fetchurl, stdenvNoCC, undmg, p7zip, libarchive, unzip }:

stdenvNoCC.mkDerivation rec {
  pname = "adobe-reader";
  version = "2500120467";

  # https://ardownload2.adobe.com/pub/adobe/acrobat/mac/AcrobatDC/2500120467/AcroRdrSCADC2500120467_MUI.dmg

  src = fetchurl {
    url =
      "https://ardownload2.adobe.com/pub/adobe/acrobat/mac/AcrobatDC/${version}/AcroRdrSCADC${version}_MUI.dmg";
    sha256 = "sha256-6c1AZfhfdxOlk0VwhAck3zJQvJFRuDr5PuTLGBvInXQ=";
  };

  nativeBuildInputs = [ undmg p7zip libarchive unzip ];

  decompressScript = ../../scripts/adobe-pdf-reader-decompress; # from content

  unpackPhase = ''
    undmg $src
    7z x *.pkg
    ls -la
    cd application_mini_7z.pkg
    bsdtar -xf Payload
    cd ..
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    mv application_mini_7z.pkg/"Adobe Acrobat.app" "$out/Applications"

    (cd $out/Applications/*.app/Contents && bash ${decompressScript})

    runHook postInstall
  '';
}

