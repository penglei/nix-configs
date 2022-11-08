# dhcpv4 server
{ config, lib, ... }: {
  services.kea = {
    # ctrl-agent = { enable = true; };
    dhcp4 = {
      enable = lib.mkDefault false;
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
          subnet = config.netaddr.ipv4.subnet.all;
          pools = with config.netaddr.ipv4.subnet.dhcp_pools; [{
            pool = "${start} - ${end}";
          }];
          option-data = [{
            name = "routers";
            data = config.netaddr.ipv4.router;
          }
          # {
          #   name = "v6-only-preferred";
          #   data = "1800";
          # }
            ];
          ddns-qualifying-suffix = "lan.";
          reservations = config.netaddr.ipv4.subnet.reservations;
        }];
        option-data = [
          {
            name = "domain-name-servers";
            data = config.netaddr.ipv4.dns;
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
