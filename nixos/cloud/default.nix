{ modulesPath, lib, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../nix.nix
    ../modules/configuration.nix
    ../modules/programs.nix
    ../modules/openssh.nix
    ../modules/pam.nix
  ];

  boot.initrd.availableKernelModules =
    [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.initrd.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  boot.loader = {
    grub.enable = true;
    grub.devices = [ "/dev/vda" ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  networking.firewall.enable = false;

  system.stateVersion = lib.mkDefault "22.11";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
