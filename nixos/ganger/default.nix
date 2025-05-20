{ config, lib, pkgs, ... }:

{
  imports = [
    ../nix.nix
    ../../secrets # common sops config
    ../modules/configuration.nix
    ../modules/programs.nix
    ../modules/pam.nix
    ../modules/openssh.nix

    #{as router
    ../router
    ./network.nix
    #}

    ./vms
  ];

  #These modules ared loaded in boot stage-1, which are required
  #to recognize block device that contains rootfs for stage-2.
  #Run `nixos-generate-config` to determine the required modules.
  boot.initrd.availableKernelModules = [ "ahci" "megaraid_sas" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  environment.systemPackages = [ pkgs.clang ];
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

  programs.nix-ld.enable = true;

  i18n.extraLocaleSettings = {
    # date command support "en_CN.UTF-8", but glibc-locales doesn't
    LC_TIME = "zh_CN.UTF-8";
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  security.pam.loginLimits = [{
    domain = "*";
    type = "soft";
    item = "nofile";
    value = "4096";
  }];

  system.stateVersion = "23.05";
}

