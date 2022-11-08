

{ lib, fetchzip, stdenvNoCC }:

stdenvNoCC.mkDerivation rec {
  pname = "isabelle-app";
  version = "2022";

  src = fetchzip {
    url = "https://isabelle.in.tum.de/dist/Isabelle2022_macos.tar.gz";
    stripRoot = false;
    sha256 = "sha256-jy2nptJ93VUBZh4IIL6MkP3YFM5ASXePp2wZhs/jUXE=";
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
    description = "A generic proof assistant";

    longDescription = ''
      Isabelle is a generic proof assistant.  It allows mathematical formulas
      to be expressed in a formal language and provides tools for proving those
      formulas in a logical calculus.
    '';
    homepage = "https://isabelle.in.tum.de/";
    license = licenses.bsd3;
    platforms = platforms.darwin; # 10.15 is the minimum supported version.
  };
}
