{ config, ... }: {
  services.miniupnpd = {
    enable = true;
    externalInterface = config.netaddr.iface.wan.name;
    internalIPs = [ "br-lan" ];
    natpmp = true;
  };
}
