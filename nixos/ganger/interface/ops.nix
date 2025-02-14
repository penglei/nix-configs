{
  systemd.network.networks."10-eno1-ops" = {
    matchConfig.Name = "eno1";
    networkConfig = {
      DHCP = "ipv4"; # for ops lan (192.168.1.5/24)
    };
    dhcpV4Config = {
      UseDNS = false;
      UseRoutes = false;
      UseGateway = false;
    };
  };
}
