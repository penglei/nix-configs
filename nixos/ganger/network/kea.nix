let utils = import ../utils.nix;
in {
  services.kea = {
    # ctrl-agent = { enable = true; };
    dhcp4 = {
      enable = true;
      settings = {
        interfaces-config = { interfaces = [ "br-lan" ]; };
        valid-lifetime = 300;
        renew-timer = 1000;
        rebind-timer = 2000;
        lease-database = {
          type = "memfile";
          persist = true;
          name = "/var/lib/kea/dhcp4.leases";
        };
        dhcp-ddns.enable-updates = true;
        subnet4 = [{
          id = 1;
          interface = "br-lan";
          subnet = "192.168.202.0/24";
          pools = [{ pool = "192.168.202.2 - 192.168.202.100"; }];
          option-data = [
            {
              name = "routers";
              data = "192.168.202.1";
            }
            {
              name = "v6-only-preferred";
              data = "1800";
            }
          ];
          ddns-qualifying-suffix = "lan.";
          reservations = [
            {
              hw-address = "44:A8:42:20:80:92";
              ip-address = "192.168.202.170";
              # hostname = "ganger";
            }
            {
              hw-address = utils.gen_mac "vm-1";
              ip-address = "192.168.202.2";
              hostname = "lan-vm-1";
            }
            {
              hw-address = "A0:63:91:95:95:3E";
              ip-address = "192.168.202.254";
              hostname = "switch";
            }
          ];
        }];
        option-data = [
          {
            name = "domain-name-servers";
            data = "192.168.202.1";
            always-send = true;
          }
          {
            name = "domain-search";
            data = "lan.";
          }
        ];
      };
    };
  };
}
