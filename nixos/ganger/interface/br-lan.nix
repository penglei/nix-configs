{
  systemd.network.netdevs."br-lan" = {
    netdevConfig = {
      Name = "br-lan";
      Kind = "bridge";
    };
  };
  systemd.network.networks."10-lan-bridge" = {
    matchConfig.Name = "br-lan";
    networkConfig = {
      # Address = [ "192.168.202.1/24" "2001:db8::a/64" ];
      Address = [ "192.168.202.1/24" ];
      # Gateway = "192.168.202.1"; #don't specify gateway which would add a default route unexpectly.
      #DNS = [ "192.168.101.1" ];
      IPv6AcceptRA = true;
      IPMasquerade = "ipv4";
      # IPv4Forwarding = true;
    };
    #linkConfig.RequiredForOnline = "routable";
  };
}
