let utils = import ../utils.nix;
in {
  ### interfaces ###
  systemd.network = {
    networks."10-lan-iface" = {
      matchConfig.Name = "eno3";
      networkConfig = {
        Bridge = "br-lan";

        # debug
        # DHCP = "ipv4";
        #IPv6AcceptRA = true;
        # IPv4Forwarding = true;
      };
      #linkConfig.RequiredForOnline = "routable";
      dhcpV4Config = {
        UseDNS = false;
        UseRoutes = true;
        UseGateway = false;
      };
    };

    networks."10-wan-iface" = {
      matchConfig.Name = "eno1";
      networkConfig = { Bridge = "br-wan"; };
    };

    networks."11-ops" = {
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
  };

  ### network config ###
  netaddr.ipv4 = {
    router = "192.168.101.100";
    subnet.all = "192.168.101.0/24";
    subnet.dhcp_pools = {
      start = "192.168.101.2";
      end = "192.168.101.100";
    };
    subnet.reservations = [
      {
        hw-address = utils.gen_mac "vm-1";
        ip-address = "192.168.101.2";
        hostname = "lan-vm-1";
      }
      {
        hw-address = "A0:63:91:95:95:3E";
        ip-address = "192.168.101.254";
        hostname = "switch";
      }
    ];
  };
}
