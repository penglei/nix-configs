{ hostname, username, pkgs, ... }:

{
  imports = [
    ../../nix.nix
    ../../modules/configuration.nix
    ../../modules/programs.nix
    ../../modules/pam.nix
    ../../modules/openssh.nix

    ../default.nix # router framework
    ./interface.nix # router network/interface config
    ./override.nix # router ad-hoc config
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
    #dhcpcd.enable = true; #for router, we diable it
    #resolvconf.enable = true; #enabled by services.resolved 
    #useDHCP = true; #for router, we disable it
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

