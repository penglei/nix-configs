{ lib, ... }:

let False = lib.mkForce false;
in {
  #{ developing & debug
  services.dnsmasq.enable = False;
  services.kea.dhcp4.enable = False;
  services.radvd.enable = False;
  systemd.services.mosdns.enable = False;
  systemd.services.ddns-go.enable = False;
  #}

  systemd.network.networks."01-trunk-eth" = {
    matchConfig.Name = "enp3s0";
    networkConfig = { VLAN = [ "lan.101" "wan.1195" ]; };
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
    dhcpV4Config = {
      UseDNS = false;
      UseRoutes = false;
      UseGateway = false;
    };
  };

  systemd.network.networks."10-wan-iface" = {
    matchConfig.Name = "wan.1195";
    networkConfig = { Bridge = "br-wan"; };
  };

  systemd.network.networks."11-ops" = {
    matchConfig.Name = "br-wan"; # Why this device? To bring up it!
    networkConfig = { DHCP = "ipv4"; }; # TODO static ip?
    dhcpV4Config = {
      UseDNS = false;
      UseRoutes = true;
      UseGateway = false;
    };
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
        hw-address = "70:85:c2:20:32:84";
        ip-address = "192.168.101.1";
      }
      {
        hw-address = "7a:9b:4f:16:27:94";
        ip-address = "192.168.101.50"; # macos: fixpoint
      }
    ];
  };
}
