{ config, ... }: {

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  };

  sops-keys = [ "nix/access-tokens" ];
  sops.templates."nix-extra-options" = {
    content = "access-tokens = ${config.sops.placeholder."nix/access-tokens"}";
    mode = "0400";
  };
  nix.extraOptions =
    "!include ${config.sops.templates."nix-extra-options".path}";
}
