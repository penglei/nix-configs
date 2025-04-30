{ pkgs, ... }:
let
  configFile = pkgs.writeText "chinadns-ng.conf" ''
    # 监听地址和端口
    bind-addr 0.0.0.0
    bind-port 5353

    # 国内上游、可信上游
    china-dns 223.5.5.5
    trust-dns tcp://8.8.8.8

    # 域名列表，用于分流
    chnlist-file /var/lib/chinadns/chnlist.txt
    gfwlist-file /var/lib/chinadns/gfwlist.txt
    # chnlist-first

    # 收集 tag:chn、tag:gfw 域名的 IP (可选)
    add-tagchn-ip chnip,chnip6
    add-taggfw-ip gfwip,gfwip6

    # 测试 tag:none 域名的 IP (针对国内上游)
    ipset-name4 chnroute
    ipset-name6 chnroute6

    # dns 缓存
    cache 4096
    cache-stale 86400
    cache-refresh 20

    # verdict 缓存 (用于 tag:none 域名)
    verdict-cache 4096

    # 详细日志
    # verbose
  '';

in {
  systemd.services.chinadns = {
    description = "chinadns-ng daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    preStart = ''
      statedir=/var/lib/chinadns
      mkdir -p ''${statedir}
      touch ''${statedir}
    '';
    serviceConfig = {
      ExecStart = "${pkgs.chinadns-ng}/bin/chinadns-ng -C ${configFile}";
    };
  };
}
