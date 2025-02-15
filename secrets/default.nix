{ lib, config, ... }:

{
  options = {
    sops-keys = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ "main-password" ];
      description = "sops secrets";
    };
  };
  config = {
    sops = {
      defaultSopsFile = ./secrets.yaml;
      secrets = (builtins.listToAttrs (builtins.map (k: {
        name = k;
        value = {
          #sopsFile = ./secrets.yaml;
        };
      }) config.sops-keys));
    };
  };
}
