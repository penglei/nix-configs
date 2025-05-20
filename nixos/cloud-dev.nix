{ hostname, lib, pkgs, ... }: {

  fileSystems."/data" = {
    device = "/dev/disk/by-label/data";
    fsType = "btrfs";
  };

  boot.kernelModules = [ "wireguard" ];

  networking = {
    hostName = hostname;
    useDHCP = lib.mkDefault true;
    useNetworkd = true;
    nftables.enable = true;
  };

  services.openssh = { ports = [ 22 36000 ]; };

  #this also enable 'services.resolved'
  systemd.network.enable = true;
  systemd.services."systemd-networkd" = {
    environment.SYSTEMD_LOG_LEVEL = "debug";
  };

  services.timesyncd.enable = true;

  environment.systemPackages = with pkgs; [
    wireguard-tools
    tcpdump
    python3
    buildah
    skopeo
    podman
    iotop
    iftop
  ];
  system.stateVersion = "23.05";
}
