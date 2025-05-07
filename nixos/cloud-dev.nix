{ lib, hostname, ... }: {

  fileSystems."/data" = {
    device = "/dev/disk/by-label/data";
    fsType = "btrfs";
  };
  # boot.initrd.supportedFilesystems = [ "btrfs" ];

  networking = {
    hostName = hostname;
    useDHCP = lib.mkDefault true;
    useNetworkd = true;
    nftables.enable = true;
  };

  #this also enable 'services.resolved'
  systemd.network.enable = true;
  systemd.services."systemd-networkd" = {
    environment.SYSTEMD_LOG_LEVEL = "debug";
  };

  services.timesyncd.enable = true;

  system.stateVersion = "23.05";
}
