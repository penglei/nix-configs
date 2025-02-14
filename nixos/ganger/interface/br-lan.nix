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
      #Address = [ "192.168.202.1/24" "2001:db8::a/64" ];
      Address = [ config.netaddr.ipv4.router ];
      # Gateway = "192.168.202.1"; #don't specify gateway which would add a default route unexpectly.
      #IPv6AcceptRA = true;

      #masquerade is provided by router, not the self host in the lan network
      #IPMasquerade = "ipv4";
      # IPv6SendRA = true;
      # IPv4Forwarding = true;
    };
    routes = [{
      Destination = config.netaddr.ipv4.subnet.all;
      # Gateway = "192.168.202.1";
      Metric = 1024;
    }];
    #linkConfig.RequiredForOnline = "routable";
  };

  #❯ ip route list table all
  systemd.network.config.routeTables = { custom = 200; };
}
