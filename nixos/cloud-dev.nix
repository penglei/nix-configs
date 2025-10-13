{
  hostname,
  lib,
  pkgs,
  ...
}:
{

  imports = [ ./modules/keeping.nix ];
  fileSystems."/data" = {
    device = "/dev/disk/by-label/data";
    fsType = "btrfs";
  };

  boot.loader.timeout = 1;
  boot.kernelModules = [ "wireguard" ];

  networking = {
    hostName = hostname;
    useDHCP = lib.mkDefault true;
    useNetworkd = true;
    nftables.enable = true;
  };

  services.openssh = {
    ports = [
      22
      36000
    ];
  };

  #this also enable 'services.resolved'
  systemd.network.enable = true;
  systemd.services."systemd-networkd" = {
    environment.SYSTEMD_LOG_LEVEL = "debug";
  };

  #This is important for vscode server
  programs.nix-ld.enable = true;

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

    unzip
  ];
  system.stateVersion = "23.05";
}
