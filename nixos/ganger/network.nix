{ lib, ... }:
let
  utils = import ../utils.nix;
  False = lib.mkForce false;
in {

  # disable router (ipv4, ipv6)
  services.kea.dhcp4.enable = False;
  services.radvd.enable = False;
  # systemd.services.dhcpcd-pd.enable = False;
  #

  systemd.services.ddns-go.enable = False;

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

  ### vpn
  services.netbird = { enable = true; };
}
