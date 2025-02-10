{

  services.miniupnpd = {
    enable = true;
    externalInterface = "pppoe-wan";
    internalIPs = [ "br-lan" ];
    natpmp = true;
  };
}
