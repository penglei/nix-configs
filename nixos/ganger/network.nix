let utils = import ../utils.nix;
in {

  #{ develop and debug router
  services.coredns.enable = true;

  #vpn
  services.netbird.enable = true;
  #}

  ### interfaces ###
  systemd.network = {
    networks."10-lan-iface" = {
      matchConfig.Name = "eno3";
      networkConfig = {
        Bridge = "br-lan";

        ## debug
        #DHCP = "ipv4";
        #IPv6AcceptRA = true;
        #IPv4Forwarding = true;
      };
    };
    networks."10-wan-iface" = {
      matchConfig.Name = "eno1";
      networkConfig = { Bridge = "br-wan"; };
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
    subnet.reservations = [{
      hw-address = utils.gen_mac "vm-1";
      ip-address = "192.168.101.2";
      hostname = "lan-vm-1";
    }];
  };
  # netaddr.ipv6 = { router = "fd00:1000:2000::100/64"; };

}
