{
  systemd.network.networks."10-eno1-ops" = {
    matchConfig.Name = "eno1";
    networkConfig = {
      DHCP = "ipv4"; # ops lan
    };
    dhcpV4Config = {
      UseDNS = false;
      UseRoutes = false;
      UseGateway = false;
    };
  };
}
