{ lib, pkgs, ... }:

{
  imports = [
    ../nix.nix
    ../modules/configuration.nix
    ../modules/programs.nix
    ../modules/pam.nix
  ];

  boot.initrd.availableKernelModules =
    [ "nvme" "virtio_pci" "xhci_pci" "usbhid" "virtiofs" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

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

  networking = { useDHCP = lib.mkDefault true; };
  environment.systemPackages = with pkgs; [ htop ];
  services.timesyncd.enable = false;
  system.stateVersion = "23.11";
}
