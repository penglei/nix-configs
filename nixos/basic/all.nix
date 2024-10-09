# { lib, ... }:

{
  imports = [
    ../nix.nix
    ../modules/configuration.nix
    ../modules/programs.nix
    ./hardware-configuration.nix
    ./networking.nix
    ./services.nix
  ];

}
