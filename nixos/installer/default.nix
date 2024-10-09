{ lib, ... }:

{
  imports = [
    #只能配置一个
    ./efi.nix
    #./grub.nix
  ] ++ [
    ../nix.nix
    ../modules/configuration.nix
    ../modules/programs.nix

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
      boot.initrd.availableKernelModules =
        [ "nvme" "virtio_pci" "xhci_pci" "usbhid" ];
      boot.initrd.kernelModules = [ ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };

      fileSystems."/boot/efi" = {
        device = "/dev/disk/by-uuid/D72B-3811";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

      #fileSystems."/boot" = {
      #  device = "/dev/disk/by-label/boot";
      #  fsType = "vfat";
      #};
    })
  ];

  boot.kernelParams = [ "console=ttyS0,115200" "console=tty1" ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}

