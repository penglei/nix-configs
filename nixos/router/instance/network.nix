{
  services.dnsmasq.enable = true;
  services.ddns.enable = true;

  systemd.network.networks."01-vlan-trunk" = {
    matchConfig = { Name = "enp3s0"; };
    linkConfig = {
      #Unmanaged = true;
      RequiredForOnline = false;
    };
    networkConfig = {
      VLAN = [ "lan.101" "wan.1195" ];
      KeepMaster = true; # to make the link enter 'configured' state
    };
  };

  systemd.network.netdevs."02-vlan.1195-wan" = {
    netdevConfig = {
      Name = "wan.1195";
      Kind = "vlan";
    };
    vlanConfig = { Id = 1195; };
  };
  systemd.network.netdevs."02-vlan.101-lan" = {
    netdevConfig = {
      Name = "lan.101";
      Kind = "vlan";
    };
    vlanConfig = { Id = 101; };
  };

  systemd.network.networks."10-lan-iface" = {
    matchConfig.Name = "lan.101";
    networkConfig = { Bridge = "br-lan"; };
  };
  systemd.network.networks."10-wan-iface" = {
    matchConfig.Name = "wan.1195";
    networkConfig = { Bridge = "br-wan"; };
  };

  netaddr.ipv4 = {
    router = "192.168.101.1";
    subnet.all = "192.168.101.0/24";
    subnet.dhcp_pools = {
      start = "192.168.101.101";
      end = "192.168.101.200";
    };
    subnet.reservations = [
      {
        hw-address = "3e:22:25:a3:f9:4a";
        ip-address = "192.168.101.190";
        hostname = "fixpoint"; # m4pro
      }
      {
        hw-address = "74:e6:e2:fc:e3:2e";
        ip-address = "192.168.101.199";
        hostname = "idrac";
      }

      {
        hw-address = "00:e0:70:6b:b0:59";
        ip-address = "192.168.101.189";
        hostname = "router2";
      }

    ];
  };
  # netaddr.ipv6 = { router = "fd00:1000:2000::1/64"; };
}
