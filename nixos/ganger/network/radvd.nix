{ config, pkgs, ... }:

let
  wan = config.netaddr.iface.wan.name;
  # 监控 PPPoE 接口的前缀变化
  prefixWatch = pkgs.writeScriptBin "prefix-watch" ''
    #!${pkgs.bash}/bin/bash
    while ${pkgs.inotify-tools}/bin/inotifywait -e modify /proc/net/if_inet6; do
      NEW_PREFIX=$(ip -6 addr show dev ${wan} | grep -m1 'global' | awk '{print $2}' | cut -d':' -f1-4)
      [ "$NEW_PREFIX" != "$OLD_PREFIX" ] && \
        echo "New prefix detected: $NEW_PREFIX" && \
        ${pkgs.systemd}/bin/systemctl restart radvd
      OLD_PREFIX=$NEW_PREFIX
    done
  '';

  shared = {
    systemd.services.prefix-watcher = {
      description = "IPv6 Prefix Change Watcher";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${prefixWatch}/bin/prefix-watch";
        Restart = "always";
      };
    };

    #配置局域网设备使用 IPv6，在主路由上部署 radvd 作为路由通告服务，为内网设备分配 IPv6 地址。
    services.radvd = {
      enable = true;
      debugLevel = 5;
      config = ''
        interface br-lan {
          AdvSendAdvert on;
          AdvManagedFlag off;    # 不使用 DHCPv6
          AdvOtherConfigFlag off;

          # 如果 ISP 分配的是动态前缀
          prefix ::/64 {
            AdvAutonomous on;     # 允许SLAAC
            AdvOnLink on;
            AdvRouterAddr on;
            AdvValidLifetime 86400;
            AdvPreferredLifetime 14400;
            Base6Interface pppoe-wan; # 从 PPPoE 接口获取前缀
          };

          # ULA 备用配置
          prefix fd12:3456:789a::/64 {
            AdvPreferredLifetime 86400;
            AdvValidLifetime 604800;
          };
        }; 
      '';
    };

    # services.ndppd = {
    #   enable = true;
    #   proxies = {
    #     pppoe-wan = {
    #       rules."??" = {
    #         method = "static";
    #       };
    #     };
    #   };
    # };
  };

in {
  services.radvd = {
    enable = true;
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
