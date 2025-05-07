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
    # don't run build.sh directly, as the build environment(chroot) doesn't bring the /usr/bin/env
    bash $src/hack/build.sh $out
    python3 -c '${sops_replace_py}' $out/config.json > config.json
    mv config.json $out/
    cp $out/config.json $out/template.txt
  '';
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
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

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
      ln -s ${configFilePath} $STATE_DIRECTORY/config.json
    '';
    postStart = ''
      # setup route and nftables
      ${./sing-box/hack/intercept.sh} start
    '';
    serviceConfig = {
      StateDirectory = "sing-box";
      StateDirectoryMode = "0700";
      RuntimeDirectory = "sing-box";
      RuntimeDirectoryMode = "0700";
      ExecStart = let bin = lib.getExe pkgs.sing-box-prebuilt;
      in [
        "" # firstly, clean others definition
        "${bin} -D \${STATE_DIRECTORY} -C \${RUNTIME_DIRECTORY} run -c config.json"
      ];
    };
    preStop = ''
      ${./sing-box/hack/intercept.sh} stop
    '';
    postStop = ''
      #TODO notify mosdns forwarding dns query to outside
    '';
    wantedBy = [ "multi-user.target" ];
  };

}

