{ config, lib, pkgs, ... }:
let
  PPPoELocalAddrIPv4 = "/var/lib/pppoe/local-ipv4";
  cfg = config.services.ddns;
in {

  options = {
    services.ddns.enable = lib.mkEnableOption "ddns updating watcher";
  };

  config = lib.mkIf cfg.enable {

    sops-keys = [
      "ddns/oray/auth" # username:password
    ];

    sops.templates."ddns.sh" = {
      mode = "0700";
      content = ''
        #!/usr/bin/env bash

        set -euo pipefail;

        LOCAL_ADDR_IPV4="$(cat ${PPPoELocalAddrIPv4})"

        ORAY_DOMAIN=160u61h456.iask.in
        ORAY_AUTH="${config.sops.placeholder."ddns/oray/auth"}"

        #e.g. curl -fsS "http://[USERNAME[:PASSWORD]]@ddns.oray.com/ph/update?hostname=DOMAIN[&myip=IP]"
        curl -fsS "http://$ORAY_AUTH@ddns.oray.com/ph/update?hostname=$ORAY_DOMAIN&myip=$LOCAL_ADDR_IPV4"
        echo "$(date): [$ORAY_DOMAIN] -> $LOCAL_ADDR_IPV4 [Done]"
      '';
    };

    # 1. 首次启动触发路径单元（监控文件存在）
    systemd.paths.pppoe-ddns-address-trigger = {
      enable = lib.mkDefault true;
      description = "Trigger to update ddns while pppoe has started";
      wantedBy = [ "multi-user.target" ];

      pathConfig = {
        PathExists = PPPoELocalAddrIPv4;
        Unit = "ddns";
      };
    };

    # 2. 文件变动监控路径单元（监控内容变化）
    systemd.paths.pppoe-ddns-update-trigger = {
      description = "Trigger to update ddns while pppoe address has changed";
      wantedBy = [ "multi-user.target" ];

      pathConfig = {
        PathChanged = PPPoELocalAddrIPv4;
        Unit = "ddns.service";
      };
    };

    # 3. 更新ddns的服务
    systemd.services.ddns = {
      enable = lib.mkDefault true;

      description = "Update dns address";

      wantedBy = [ ]; # 禁用默认启动

      path = with pkgs; [ bash gawk curl ];
      serviceConfig = let entrypoint = config.sops.templates."ddns.sh".path;
      in {
        Type = "oneshot";

        # StateDirectory = "ddns"; #/var/lib/ddns
        # StateDirectoryMode = "0700";

        # env is just available for process(child), not for parent to run.
        # ExecStart = "${pkgs.bash}/bin/bash ${entrypoint}";
        ExecStart = "${entrypoint}";
        Restart = "on-failure";
        RestartSec = "30s";
      };
    };
  };
}

