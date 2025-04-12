{
  systemd.network.netdevs."20-vlan.1195-wan" = {
    netdevConfig = {
      Name = "wan.1195";
      Kind = "vlan";
    };
    vlanConfig = { Id = 1195; };
  };

  systemd.network.netdevs."20-vlan.101-lan" = {
    netdevConfig = {
      Name = "lan.101";
      Kind = "vlan";
    };
    vlanConfig = { Id = 101; };
  };

  systemd.network.networks."21-join-lan-bridge" = {
    matchConfig.Name = "lan.101";
    networkConfig = { Bridge = "br-lan"; };
  };

  systemd.network.networks."21-join-wan-bridge" = {
    matchConfig.Name = "wan.1195";
    networkConfig = { Bridge = "br-wan"; };
  };

  netaddr.ipv4 = {
    router = "192.168.101.1";
    subnet.all = "192.168.101.0/24";
    subnet.dhcp_pools = {
      begin = "192.168.101.101";
      end = "192.168.101.254";
    };
    subnet.reservations = [{
      hw-address = "70:85:c2:20:32:84";
      ip-address = "192.168.101.1";
    }];
  };
}
