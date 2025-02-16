{ lib, ... }:
let
  utils = import ./utils.nix;
  iface = {
    wan.nic = "eno1";
    wan.name = "pppoe-wan";
  };
  ipv4 = rec {
    router = "192.168.101.100";
    subnet.all = "192.168.101.0/24";
    subnet.dhcp_pools = {
      begin = "192.168.101.2";
      end = "192.168.101.100";
    };
    subnet.reservations = [
      {
        hw-address = "44:A8:42:20:80:92";
        ip-address = "192.168.101.170";
        # hostname = "ganger";
      }
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
    gateway = router;
    dns = router;
  };
  ipv6 = { };
in {
  options = {
    netaddr = {
      ipv4 = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = { };
      };
      ipv6 = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = { };
      };
      iface = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = { };
      };
    };
  };
  config = {
    netaddr.ipv4 = ipv4;
    netaddr.ipv6 = ipv6;
    netaddr.iface = iface;
  };
}
