{ config, lib, ... }:

{
  imports = [
    ../nix.nix
    ../modules/configuration.nix
    ../modules/programs.nix

    {
      boot.loader.grub.enable = true;
      boot.loader.grub.device = "/dev/sda";
    }

    #openssh
    {
      services.openssh.enable = true;
      services.openssh.settings.PasswordAuthentication = false;
      services.openssh.settings.PermitRootLogin = "yes";
    }

    #hostname
    ({ hostname, ... }: { networking = { hostName = hostname; }; })

    #hardwares
    ({
      boot.initrd.availableKernelModules = [ "ahci" "megaraid_sas" ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };

    })
  ];

  boot.kernelParams = [ "console=ttyS0,115200" "console=tty1" ];

  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno1.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno2.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno3.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno4.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  system.stateVersion = "23.05";
}

