{ kubectx, stdenvNoCC, bash, fetchurl }:
stdenvNoCC.mkDerivation rec {
  pname = "kubectl-kubecm";
  version = "0.21.0";

  src = fetchurl {
    url =
      "https://github.com/sunny0826/kubecm/releases/download/v0.21.0/kubecm_v0.21.0_Darwin_arm64.tar.gz";
    sha256 = "sha256-3HnUSlysTBFIfklYJ1ouUEF5iy/Jt9QQjF/KBWRu5DU=";
  };

  # Work around the "unpacker appears to have produced no directories"
  # case that happens when the archive doesn't have a subdirectory.
  setSourceRoot = "sourceRoot=`pwd`";

  buildInputs = [ bash ];
  installPhase = ''
    runHook preInstall

    install -m755 ./kubecm -D $out/bin/kubectl-kubecm

    runHook postInstall
  '';
}
