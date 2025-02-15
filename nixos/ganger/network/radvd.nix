{
  #配置局域网设备使用 IPv6，在主路由上部署 radvd 作为路由通告服务，为内网设备分配 IPv6 地址。

  services.radvd = {
    enable = true;
    debugLevel = 5;
    config = ''
      interface br-lan {
        AdvSendAdvert on;
        AdvManagedFlag off;
        AdvOtherConfigFlag off;
        prefix ::/64 {
          AdvOnLink on;
          AdvAutonomous on;
        };
      };
    '';
  };
}
