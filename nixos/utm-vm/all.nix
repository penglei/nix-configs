{
  imports = [
    ../nix.nix
    ../modules/configuration.nix
    ../modules/programs.nix
    ../modules/dnscrypt-proxy-client.nix
    ../modules/ssserver.nix
    ./hardware-configuration.nix
    ./networking.nix
    ./sops.nix
    ./networking.nix
    ./services.nix
    ./misc.nix
  ];

  system.stateVersion = "22.05";
}
