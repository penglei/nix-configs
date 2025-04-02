{ hostname, username, pkgs, ... }:

{
  imports = [
    ../nix.nix
    ../modules/configuration.nix
    ../modules/programs.nix
    ../modules/pam.nix
    ../modules/openssh.nix
  ];

  boot.initrd.availableKernelModules = [ "ahci" "usbhid" ];

  boot.loader = {
    grub.enable = true;
    grub.devices = [ "/dev/sda" ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  networking = {
    #使用 dhcpcd, resolvconf 管理网络配置，因此打开这两个配置。
    dhcpcd.enable = true;
    resolvconf.enable = true;

    useDHCP = true;
    hostName = hostname;
  };
  users = {
    mutableUsers = true;
    users.${username}.hashedPassword =
      "$6$hhh$QTt9LG93fOjTHzydcPGwX8IvXBPLQNpi/Pg.rX974mTqe7zQhHJgeqfIn/mRqeWs1KCn8hwH3YIvZ3Lc/jfre1";
  };
  environment.systemPackages = with pkgs; [ htop ];
  services.timesyncd.enable = false;
  system.stateVersion = "23.11";
}

