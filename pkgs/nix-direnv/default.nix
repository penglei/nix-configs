{ lib, stdenv, gnugrep, jq, nix }:
stdenv.mkDerivation rec {
  pname = "nix-direnv";
  version = "2.2.0";

  src = [ ./direnvrc ];

  #unpackPhase = ''
  #  src=$PWD
  #'';

  unpackPhase = ''
    for srcFile in $src; do
      cp $srcFile $(stripHash $srcFile)
    done
  '';

  # Substitute instead of wrapping because the resulting file is
  # getting sourced, not executed:
  postPatch = ''
    sed -i "1a NIX_BIN_PREFIX=${nix}/bin/" direnvrc
    substituteInPlace direnvrc --replace "grep" "${gnugrep}/bin/grep"
    substituteInPlace direnvrc --replace "jq" "${jq}/bin/jq"
  '';

  installPhase = ''
    runHook preInstall
    install -m500 -D direnvrc $out/share/nix-direnv/direnvrc
    runHook postInstall
  '';

  meta = with lib; {
    description = "A fast, persistent use_nix implementation for direnv";
    homepage = "https://github.com/nix-community/nix-direnv";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ mic92 bbenne10 ];
  };
}

