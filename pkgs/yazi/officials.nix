{ stdenvNoCC, fetchFromGitHub, }:

let
  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "8ed253716c60f3279518ce34c74ca053530039d8";
    hash = "sha256-xY2yVCLLcXRyFfnmyP6h5Fw+4kwOZhEOCWVZrRwXnTA=";
  };

in builtins.listToAttrs (map (pname: {
  name = pname;
  value = stdenvNoCC.mkDerivation {
    inherit pname src;
    version = "main";
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r ${pname}.yazi/* $out
      runHook postInstall
    '';

  };
}) [ "full-border" "git" "max-preview" "lsar" ])

