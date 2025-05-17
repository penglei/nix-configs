{ pkgs, lib, config, ... }:
let

  configFile = "sing-box-client/config.json";
  configFilePath = config.sops.templates."${configFile}".path;
  #`pkg.writeText` will store sensitive data in `/nix/store`, which is accessible to everyone.
  #configFilePath = pkgs.writeText "config.json" (builtins.toJSON cfg); 
  sops_replace_py = ''
    import re, hashlib, sys
    print(
      re.sub(
        r"<PLACEHOLDER:([^>]+)>|\"<RAW-PLACEHOLDER:([^>]+)>\"",
        lambda m:
          "<SOPS:"+hashlib.sha256((m.group(1) or m.group(2)).encode()).hexdigest()+":PLACEHOLDER>",
        open(sys.argv[1]).read()), end="")
  '';
  templates = pkgs.runCommand "sing-box-config-template" {
    src = ./sing-box;
    buildInputs = [
      pkgs.bash
      pkgs.coreutils-full

      #nickel renders configuration in first stage:
      # render to json that contains custom key placeholder: <PLACEHOLDER:keypath>
      pkgs.nickel

      #python renders configuration in second stage:
      # replace custom key placeholer to sops key placeholder: <PLACEHOLDER:key's sha256>
      pkgs.python3Minimal
    ];
  } ''
    export GATEWAY_ADDR=${config.netaddr.ipv4.gateway}
    export CHINA_DNS_SERVER="<CHINA-DNS-SERVER>"

    # Run by bash command instead of run build.sh directly,
    # because the build environment(chroot) doesn't provide the /usr/bin/env
    bash $src/hack/build.sh $out

    python3 -c '${sops_replace_py}' $out/config.json > config.json
    mv config.json $out/
    cp $out/config.json $out/template.txt
  '';
  PPPoEDNSServersFile = "/var/lib/pppoe/dns-servers";
in {

  sops-keys = [
    "main-password"
    "sing-box/sv-alpha/v2ray-plugin/opts"
    "sing-box/sv-alpha/address"
    "sing-box/sv-alpha/shadowtls/server_name"
    "sing-box/hk-alpha/address"
    "sing-box/hk-alpha/shadowtls/server_name"

    "proxies/subscribe-a/common/server"
    "proxies/subscribe-a/server1/port"
    "proxies/subscribe-a/common/method"
    "proxies/subscribe-a/common/password"
    "proxies/subscribe-a/common/plugin"
    "proxies/subscribe-a/common/plugin_opts"

    "proxies/subscribe-b/server1/addr"
    "proxies/subscribe-b/common/port"
    "proxies/subscribe-b/common/method"
    "proxies/subscribe-b/common/password"
  ];

  sops.templates."${configFile}" = {
    # content = builtins.readFile ./templates/config.json;
    content = builtins.readFile "${templates}/config.json";
    mode = "0400";
  };

  environment.systemPackages = [ pkgs.sing-box-prebuilt ];

  systemd.packages = [ pkgs.sing-box-prebuilt templates ];
  systemd.services.sing-box = {
    wantedBy = [ ]; # 禁用默认启动

    path = with pkgs; [ iproute2 nftables bash ];
    #preStart = ''
    #  echo "working directory: $(pwd)"
    #  echo "RUNTIME_DIRECTORY: $RUNTIME_DIRECTORY"
    #  rm -f ''${STATE_DIRECTORY}/rule_exts;
    #  ln -sf ${./templates/rule_exts} $STATE_DIRECTORY/rule_exts
    #'';
    preStart = ''
      rm -f ''${STATE_DIRECTORY}/rule_exts;
      ln -sf ${templates}/rule_exts $STATE_DIRECTORY/rule_exts
      rm -f $STATE_DIRECTORY/config.json

      #TODO PathModified: https://systemd-book.junmajinlong.com/systemd_path.html
      CHINA_DNS_SERVER="$(head -n 1 ${PPPoEDNSServersFile} | tr -d \\\n)"
      cat ${configFilePath} | sed "s/<CHINA-DNS-SERVER>/''${CHINA_DNS_SERVER:-119.29.29.29}/" > $STATE_DIRECTORY/config.json
    '';
    postStart = ''
      # setup route and nftables
      ${./sing-box/hack/intercept.sh} start
      nft destroy chain inet global-proxy prerouting-proxygate
    '';
    serviceConfig = {
      StateDirectory = "sing-box";
      StateDirectoryMode = "0700";
      RuntimeDirectory = "sing-box";
      RuntimeDirectoryMode = "0700";
      ExecStart = let bin = lib.getExe pkgs.sing-box-prebuilt;
      in [
        # firstly, clean others definition
        ""

        # '-C /run/sing-box' specify merge-able json config files (array append, map key ignore...)
        "${bin} -D \${STATE_DIRECTORY} -C \${RUNTIME_DIRECTORY} run -c config.json"
      ];
      Restart = "on-failure";
      RestartSec = "10s";
    };
    preStop = ''
      ${./sing-box/hack/intercept.sh} stop
    '';
    postStop = ''
      nft add chain inet global-proxy prerouting-proxygate  '{ type filter hook prerouting priority mangle - 1; policy accept; }'
    '';
  };

  # 1. 首次启动触发路径单元（监控文件存在）
  systemd.paths.pppoe-sing-box-trigger = {
    description = "Monitor pppoe dns servers file to start sing-box";
    wantedBy = [ "multi-user.target" ];

    pathConfig = {
      PathExists = PPPoEDNSServersFile;
      Unit = "sing-box.service";
      MakeDirectory = false; # 不自动创建目录
    };
  };

  # 2. 文件变动监控路径单元（监控内容变化）
  systemd.paths.pppoe-sing-box-restart-trigger = {
    description = "Trigger restarting sing-box when pppoe dns servers changes";
    wantedBy = [ "multi-user.target" ];
    pathConfig = {
      PathChanged = PPPoEDNSServersFile; # 内容或元数据变化时触发
      Unit = "sing-box-restart.service"; # 指向重启服务
    };
  };

  # 3. 定义重启服务（实际执行重启操作）
  systemd.services.sing-box-restart = {
    description = "Restart sing-box on pppoe dns servers change";
    serviceConfig = {
      Type = "oneshot";
      ExecStart =
        "${config.systemd.package}/bin/systemctl restart sing-box.service";
    };
  };
}

