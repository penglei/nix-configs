{
  networking = { useNetworkd = true; };

  systemd.network.networks."20-eth" = {
    matchConfig.Name = "ens3";

    networkConfig = {
      DHCP = "ipv4";
      Address = [ "240d:c000:f07f:8d00:acb8:fb6a:24fa:1" ];
    };
    routes = [{
      Destination = "::/0";
      Gateway = "fe80::feee:ffff:feff:ffff";
      #GatewayOnLink = true; # 表示网关在直接连接的链路上
    }];
    dhcpV4Config = {
      UseDNS = true;
      UseRoutes = true;
      UseGateway = true;
    };
  };
}
