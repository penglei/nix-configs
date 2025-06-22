{ config, pkgs, ... }:
let

  statedir = "/var/lib/chinadns";
  configFile = pkgs.writeText "chinadns-ng.conf" ''
    # 监听地址和端口
    bind-addr 0.0.0.0
    bind-port 5353

    # 国内上游
    china-dns 223.5.5.5,120.53.53.53

    # 可信上游
    #udp://127.0.0.1#29753,tcp://8.8.8.8
    #trust-dns tcp://8.8.8.8
    trust-dns tcp://43.135.87.60#15353?count=0?life=0

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
  PPPoEDNSServersFile = "/var/lib/pppoe/dns-servers";
in
{
  systemd.services.chinadns = {
    description = "chinadns daemon";
    wantedBy = [ ]; # 禁用默认启动

    path = with pkgs; [ coreutils ];
    preStart = ''
      mkdir -p ${statedir}
      if [ ! -f ${statedir}/dirty.lock ];then

        : > ${statedir}/direct-list.txt
        cat ${./data/china-list.txt} >> ${statedir}/direct-list.txt
        cat ${./data/china-list-manual.txt} >> ${statedir}/direct-list.txt

        : > ${statedir}/proxy-list.txt
        cat ${./data/gfw.txt} >> ${statedir}/proxy-list.txt
        cat ${configFile} > ${statedir}/chinadns-ng.conf
        chinaservers=$(cat ${PPPoEDNSServersFile} | tr '\n' ',')
        if [ -n "$chinaservers" ];then
          echo "china-dns ''${chinaservers}" >> ${statedir}/chinadns-ng.conf
        fi
      fi
    '';
    # unitConfig = { ConditionPathExists = PPPoEDNSServersFile; }; # **only active** if the file exists(not expected)
    serviceConfig = {
      ExecStart = "${pkgs.chinadns-ng}/bin/chinadns-ng -C ${statedir}/chinadns-ng.conf";
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };

  # 1. 首次启动触发路径单元（监控文件存在）
  systemd.paths.pppoe-chinadns-trigger = {
    description = "Monitor pppoe dns servers file to start chinadns";
    wantedBy = [ "multi-user.target" ];

    pathConfig = {
      PathExists = PPPoEDNSServersFile;
      Unit = "chinadns.service";
      MakeDirectory = false; # 不自动创建目录
    };
  };

  # 2. 文件变动监控路径单元（监控内容变化）
  systemd.paths.pppoe-chinadns-restart-trigger = {
    description = "Trigger restarting chinadns when pppoe dns servers changes";
    wantedBy = [ "multi-user.target" ];

    pathConfig = {
      PathChanged = PPPoEDNSServersFile; # 内容或元数据变化时触发
      Unit = "chinadns-restart.service"; # 指向重启服务
      AccuracySec = "5s"; # 合并 5 秒内的连续变动为一次触发
    };
  };

  # 3. 定义重启服务（实际执行重启操作）
  systemd.services.chinadns-restart = {
    description = "Restart chinadns on pppoe dns servers change";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${config.systemd.package}/bin/systemctl restart chinadns.service";
    };
  };

}
