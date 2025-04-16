{
  systemd.network.netdevs."01-br-wan" = {
    netdevConfig = {
      Name = "br-wan";
      Kind = "bridge";
    };
  };
  systemd.network.networks."01-br-wan" = {
    matchConfig.Name = "br-wan";
    networkConfig = { DHCP = "ipv4"; };
    dhcpV4Config = {
      UseDNS = false;
      UseRoutes = false;
      UseGateway = false;
    };
  };
}

