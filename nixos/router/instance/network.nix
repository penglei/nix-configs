{ lib, ... }:

let False = lib.mkForce false;
in {
  #{ developing & debug
  services.dnsmasq.enable = False;
  services.kea.dhcp4.enable = False;
  services.radvd.enable = False;
  # systemd.services.mosdns.enable = False;
  systemd.services.ddns-go.enable = False;
  #}

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
