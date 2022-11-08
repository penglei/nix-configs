{ lib, hostname, pkgs, ... }: {

  imports = [
    (import ./default.nix)
    ((import ../modules/sing-box-server.nix) { proxy_name = "hk-alpha"; })
  ];

  swapDevices = [{
    device = "/swapfile";
    size = 2048; # 2GB
  }];

  environment.systemPackages = with pkgs; [ tcpdump ftop iotop iftop ];

  networking = {
    hostName = hostname;
    useDHCP = lib.mkDefault true; # legacy config style
    useNetworkd = true;
    nftables.enable = true;
  };

  systemd.network.enable = true;
  systemd.services."systemd-networkd" = {
    environment.SYSTEMD_LOG_LEVEL = "debug";
  };
  services.timesyncd.enable = true;

  systemd.network.networks."10-static-ipv6-route" = {
    matchConfig.Name = "ens5";

    networkConfig = {
      DHCP = "ipv4"; # must
      IPv6AcceptRA = true;
    };
    routes = [{
      Destination = "::/0"; # IPv6 默认路由
      Gateway = "fe80::feee:ffff:feff:ffff";
      GatewayOnLink = true; # 网关在本地链路
    }];
  };

  nix.settings.substituters = lib.mkForce [ "https://cache.nixos.org" ];

  system.stateVersion = "23.05";
}
