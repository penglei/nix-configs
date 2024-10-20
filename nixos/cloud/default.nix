{ modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../nix.nix
    ../modules/configuration.nix
    ../modules/programs.nix
    ../modules/openssh.nix
    ../modules/pam.nix
    ../modules/sops.nix
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

  system.stateVersion = "22.11";
}
