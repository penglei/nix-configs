{ config, ... }: {
  #router should setup ipv4 nat for lan
  networking.nat = {
    enable = true;
    externalInterface = config.netaddr.iface.wan.name;
    internalIPs = [ config.netaddr.ipv4.subnet.all ];
    forwardPorts = [ ];
    # dmzHost = [];
  };
  networking.nftables.tables = {
    "nixos-nat" = {
      family = "ip";
      content = ''
        chain post {
          type nat hook postrouting priority srcnat; policy accept;

          #nft add rule ip nixos-nat post ip saddr 192.168.101.0/24 ip daddr 192.168.1.0/24 oifname "br-wan" masquerade
          ip saddr 192.168.101.0/24 ip daddr 192.168.1.0/24 oifname "br-wan" masquerade comment "visit ops lan"
        }
      '';
    };
  };

}
