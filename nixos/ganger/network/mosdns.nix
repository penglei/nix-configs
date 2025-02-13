{ lib, pkgs, ... }:

let
  router_lan_ip = "192.168.202.1";
  # 生成 mosdns 配置文件（替换为你的实际配置）
  mosdnsConfig = pkgs.writeText "mosdns.yaml" ''
    log:
      level: info
      # file: "/var/log/mosdns.log"

    # (实验性) API 入口设置
    api:
      http: "${router_lan_ip}:8080" # 在该地址启动 api 接口。

    plugins:
      - tag: main_sequence
        type: sequence
        args:
          - exec: cache 1024
          - exec: forward 127.0.0.1:29753  #sing-box dns server

      - tag: main_server
        type: udp_server
        args:
          entry: main_sequence
          listen: ${router_lan_ip}:53
  '';
in {
  # 将 mosdns 添加到系统环境包
  systemd.packages = [ pkgs.mosdns ];

  # 配置 systemd 服务
  systemd.services.mosdns = {
    enable = true;
    description = "mosdns DNS resolver";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    # 服务配置
    serviceConfig = {
      ExecStart = "${
          lib.getExe pkgs.mosdns
        } start -d \${STATE_DIRECTORY} -c ${mosdnsConfig}";
      DynamicUser = true; # 自动创建临时用户
      User = "mosdns";
      Group = "mosdns";
      Restart = "on-failure";
      AmbientCapabilities = "CAP_NET_BIND_SERVICE"; # 允许绑定特权端口
      CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
      StateDirectory = "mosdns"; # 自动创建 /var/lib/mosdns
    };

    # # 如果使用非动态用户，需要手动创建数据目录
    # preStart = ''
    #   mkdir -p /var/lib/mosdns
    #   chown mosdns:mosdns /var/lib/mosdns
    # '';
  };
  # # 创建专用用户/组（可选，systemd 会自动创建动态用户）
  # users.users.mosdns = {
  #   isSystemUser = true;
  #   group = "mosdns";
  # };
  # users.groups.mosdns = { };
}
