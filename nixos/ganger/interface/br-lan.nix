{ config, ... }: {

  systemd.network.netdevs."br-lan" = {
    netdevConfig = {
      Name = "br-lan";
      Kind = "bridge";
    };
  };

  systemd.network.networks."10-lan-bridge" = {
    matchConfig.Name = "br-lan";
    networkConfig = {
      #Address = [config.netaddr.ipv4.subnet.all];
      Address = [ config.netaddr.ipv4.router ];
      #Specifying a gateway would add a default route unexpectly,
      #which is conflict with router.
      # Gateway = config.netaddr.ipv4.gateway;

      #host-self is not a router, don't do work of router.
      #IPMasquerade = "ipv4";
      #IPv6SendRA = true;
      #IPv4Forwarding = true;
    };
    routes = [{
      Destination = config.netaddr.ipv4.subnet.all;
      # Gateway = config.netaddr.ipv4.gateway;
      Metric = 1024;
    }];
    #linkConfig.RequiredForOnline = "routable";
  };

  #❯ ip route list table all
  systemd.network.config.routeTables = { custom = 200; };
}
