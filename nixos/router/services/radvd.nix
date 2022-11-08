{ lib, ... }:
# The Router Advertisement Daemon
#路由器广告守护进程, 发送IPv6 无状态自动配置所需的路由器广告消息
{
  # An alternative(https://bird.network.cz/)
  # services.bird = {}

  services.radvd = {
    enable = lib.mkDefault false;
    debugLevel = 5;
    config = ''
      interface br-lan {
        AdvSendAdvert on;
        AdvManagedFlag off;    # 不使用 DHCPv6
        AdvOtherConfigFlag off;

        MinRtrAdvInterval 3;
        MaxRtrAdvInterval 10;

        prefix ::/64 {
          AdvOnLink on;
          AdvAutonomous on;
          AdvRouterAddr on;
          # AdvValidLifetime 86400;
          # AdvPreferredLifetime 14400;
        };
      }; 
    '';
  };
}
