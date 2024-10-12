{ lib, ... }:

{
  imports = [
    ../nix.nix
    ../modules/configuration.nix
    ../modules/programs.nix
    ../modules/pam.nix

    ./hardware-configuration.nix
    ./networking.nix
    ./services.nix
    ./misc.nix
  ];

  system.stateVersion = "23.11";
}
