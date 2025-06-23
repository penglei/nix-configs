{ stdenvNoCC, fetchFromGitHub }:

let
  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "e5f00e2716fd177b0ca0d313f1a6e64f01c12760";
    hash = "sha256-Ry3V29T7lij5JR68gTINXtOEgbrYPwd5zQDEa2kfpTA=";
  };

in
builtins.listToAttrs (
  map
    (pname: {
      name = pname;
      value = stdenvNoCC.mkDerivation {
        inherit pname src;
        version = "main";
        installPhase = ''
          runHook preInstall
          mkdir -p $out
          cp -r * $out
          runHook postInstall
        '';

      };
    })
    [
      "full-border"
      "git"
      "max-preview"
      "lsar"
    ]
)
