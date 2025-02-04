{ modulesPath, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../nix.nix
    ../modules/configuration.nix
    ../modules/programs.nix
    ../modules/dnscrypt-proxy-client.nix
    ../modules/ssserver.nix
  ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "virtio_pci" "usbhid" "usb_storage" "sr_mod" ];
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };
  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];

  networking = {
    useDHCP = false;
    dhcpcd.enable = false;
    defaultGateway = "192.168.65.1";
    nameservers = [ "192.168.65.1" ];
    interfaces.enp0s1 = {
      ipv4.addresses = [{
        address = "192.168.65.5";
        prefixLength = 24;
      }];
    };
  };

  services.qemuGuest.enable = true;
  services.tailscale.enable = true;
  virtualisation.docker.enable = true;

  sops = {
    # age.keyFile = keyfile;
    # age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    defaultSopsFile = ../../secrets/basic.yaml;

    secrets.hello = { path = "/tmp/helloworld-from-sops"; };

    secrets."ssserver.json" = {
      sopsFile = ../../secrets/server.yaml;
      restartUnits = [ "ssserver.service" ];
    };
  };

  system.stateVersion = "22.05";
}
