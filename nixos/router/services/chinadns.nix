{ pkgs, ... }:
let
  china-list = ./data/china-list.txt;
  gfw-domains = ./data/gfw.txt;

  statedir = "/var/lib/chinadns";
  configFile = pkgs.writeText "chinadns-ng.conf" ''
    # 监听地址和端口
    bind-addr 0.0.0.0
    bind-port 5353

    # 国内上游、可信上游
    china-dns 223.5.5.5,120.53.53.53
    trust-dns udp://127.0.0.1#29753,tcp://8.8.8.8

    # 域名列表，用于分流(https://github.com/Loyalsoldier/v2ray-rules-dat)
    #https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/direct-list.txt
    chnlist-file ${statedir}/direct-list.txt

    #https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/proxy-list.txt
    gfwlist-file ${statedir}/proxy-list.txt
    # chnlist-first

    # # 收集 tag:chn、tag:gfw 域名的 IP (可选)
    # add-tagchn-ip inet@chndns-auto@chnip,inet@global@chnip6
    # add-taggfw-ip inet@chndns-auto@gfwip,inet@global@gfwip6

    # 测试 tag:none 域名的 IP (针对国内上游)
    ipset-name4 inet@global-proxy@chnroute
    ipset-name6 inet@global-proxy@chnroute6

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
      mkdir -p ${statedir}
      : > ${statedir}/direct-list.txt
      cat ${./data/china-list.txt} >> ${statedir}/direct-list.txt
      cat ${./data/china-list-manual.txt} >> ${statedir}/direct-list.txt

      : > ${statedir}/proxy-list.txt
      cat ${./data/gfw.txt} >> ${statedir}/proxy-list.txt
    '';
    serviceConfig = {
      ExecStart = "${pkgs.chinadns-ng}/bin/chinadns-ng -C ${configFile}";
    };
  };
}
