{
  imports = [
    ../nix.nix
    ../modules/configuration.nix
    ../modules/programs.nix
    ../modules/openssh.nix

    #hardwares
    {
      boot.initrd.availableKernelModules =
        [ "nvme" "virtio_pci" "xhci_pci" "usbhid" ];
      boot.initrd.kernelModules = [ ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };

      fileSystems."/boot/efi" = {
        device = "/dev/disk/by-label/boot";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

    }
  ];

  # boot loader
  boot.loader = {
    systemd-boot.enable = true;
    efi.efiSysMountPoint = "/boot/efi";
    efi.canTouchEfiVariables = true;
  };

  networking.useNetworkd = true;
  systemd.network = {
    enable = true;
    networks = {
      "10-default" = {
        enable = true;
        name = "en*";
        networkConfig = { DHCP = "yes"; };
        dhcpV4Config.RouteMetric = 1024; # Better be explicit
      };
    };
  };

  system.stateVersion = "22.11";
}

