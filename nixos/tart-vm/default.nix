{ lib, pkgs, ... }:

{
  imports = [
    ../nix.nix
    ../modules/configuration.nix
    ../modules/programs.nix
    ../modules/pam.nix
    ../modules/openssh.nix
    ../modules/sing-box-client.nix
  ];

  boot.kernelModules = [ "wireguard" ];
  boot.initrd.availableKernelModules =
    [ "nvme" "virtio_pci" "xhci_pci" "usbhid" "virtiofs" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    timeout = 1;
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/disk-main-esp";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };
  fileSystems."/" = {
    device = "/dev/disk/by-partlabel/disk-main-root";
    fsType = "ext4";
  };

  #This is important for vscode server
  programs.nix-ld.enable = true;

  networking = { useDHCP = lib.mkDefault true; };
  environment.systemPackages = with pkgs; [ htop wireguard-tools fd ];
  services.timesyncd.enable = false;
  system.stateVersion = "23.11";
}
