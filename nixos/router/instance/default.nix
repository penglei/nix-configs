{ username, pkgs, ... }:

{
  imports = [
    ../../../secrets
    ../../nix.nix
    ../../modules/configuration.nix
    ../../modules/programs.nix
    ../../modules/pam.nix
    ../../modules/openssh.nix

    ../default.nix # router framework
    ./network.nix # router network/interface config
  ];

  boot.initrd.availableKernelModules = [ "ahci" "usbhid" ];

  boot.loader = {
    timeout = 1;
    grub.enable = true;
    grub.devices = [ "/dev/sda" ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  users = {
    mutableUsers = true;
    users.${username}.hashedPassword =
      "$6$hhh$QTt9LG93fOjTHzydcPGwX8IvXBPLQNpi/Pg.rX974mTqe7zQhHJgeqfIn/mRqeWs1KCn8hwH3YIvZ3Lc/jfre1";
  };
  environment.systemPackages = [ pkgs.helix ];
  system.stateVersion = "23.11";
}

