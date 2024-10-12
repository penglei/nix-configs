{ hostname, ... }:

{
  imports = [

    # boot loader
    {
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.efiSysMountPoint = "/boot/efi";
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.timeout = 1;
      boot.kernelParams = [ "console=ttyS0,115200" "console=tty1" ];
    }

    ../nix.nix
    ../modules/configuration.nix
    ../modules/programs.nix

    #openssh
    {
      services.openssh.enable = true;
      services.openssh.settings.PasswordAuthentication = false;
      services.openssh.settings.PermitRootLogin = "yes";
    }

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
        device = "/dev/disk/by-label/boot";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

    })
  ];

  # networking.useDHCP = false;
  # networking.iproute2 = {
  #   enable = true;
  #   rttablesExtraConfig = ''
  #     200 lan1
  #   '';
  # };
  # networking.useNetworkd = true;
  networking.hostName = hostname;

  systemd.network.networks = {
    "10-default" = {
      enable = true;
      name = "en*";
      networkConfig = { DHCP = "yes"; };
      dhcpV4Config.RouteMetric = 1024; # Better be explicit
    };
  };

  system.stateVersion = "22.11";
}

