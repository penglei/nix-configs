{ config, lib, ... }:

{
  imports = [
    ../nix.nix
    ../../secrets # common sops config
    ../modules/configuration.nix
    ../modules/programs.nix
    ../modules/openssh.nix
    ../modules/pam.nix
    # ../modules/sing-box-client.nix

    ./netaddr.nix

    ./interface/ops.nix
    ./interface/pppoe.nix
    ./interface/br-lan.nix
    ./interface/lan-eno.nix

    ./network/kea.nix
    ./network/nat.nix
    ./network/mosdns.nix
    ./network/sing-box.nix
    ./network/firewall.nix
    ./network/miniupnpd.nix

    # lan ipv6
    ./network/dhcpcd-pd.nix
    ./network/radvd.nix

    ./vms
  ];

  #These modules ared loaded in boot stage-1, which are required
  #to recognize block device that contains rootfs for stage-2.
  #Run `nixos-generate-config` to determine the required modules.
  boot.initrd.availableKernelModules = [ "ahci" "megaraid_sas" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.loader = {
    timeout = 1;

    # grub.enable = true;
    # grub.device = "/dev/sda";

    systemd-boot.enable = true;
    efi.efiSysMountPoint = "/boot";
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

  #this also enable 'services.resolved', see also 'nixos/modules/system/boot/networkd.nix'.
  systemd.network.enable = true;

  #disable network scripting configuration
  #https://wiki.nixos.org/wiki/Systemd/networkd
  #https://www.reddit.com/r/NixOS/comments/1fwh4f0/networkinginterfaces_vs_systemdnetworknetworks/
  networking = {
    useNetworkd = true;
    useDHCP = false;
    nftables.enable = true;
  };

  # services.resolved.enable = false;
  networking.nameservers =
    [ config.netaddr.ipv4.dns ]; # configure nameservers manually
  services.resolved = {
    #disable llmnr
    llmnr = "false";
    #disable mdns
    extraConfig = ''
      MulticastDNS=false
    '';
    # domain = ".";
  };

  systemd.services."systemd-networkd" = {
    environment.SYSTEMD_LOG_LEVEL = "debug";
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  system.stateVersion = "23.05";
}

