{ config, ... }: {
  #router should setup ipv4 nat for lan
  networking.nat = {
    enable = true;
    externalInterface = config.netaddr.iface.wan.name;
    # internalInterfaces = [ "br-lan" ]; #how abount ipv6 traffic?
    internalIPs = [ config.netaddr.ipv4.subnet.all ];
    forwardPorts = [ ];
    # dmzHost = [];
  };

}
