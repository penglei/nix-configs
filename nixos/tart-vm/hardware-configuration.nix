{ config, lib, pkgs, modulesPath, ... }:

{

  boot.initrd.availableKernelModules =
    [ "nvme" "virtio_pci" "xhci_pci" "usbhid" "virtiofs" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.timeout = 1;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  fileSystems."/run/data" = {
    device = "com.apple.virtio-fs.automount";
    fsType = "virtiofs";
  };

  swapDevices = [ ];
}
