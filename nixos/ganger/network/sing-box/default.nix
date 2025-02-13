{ pkgs, lib, config, ... }:
let
  #This approach is not recommended, as `pkg.writeText` will store sensitive data in `/nix/store`,
  #which is accessible to everyone.
  # configFilePath = pkgs.writeText "config.json" (builtins.toJSON cfg); 

  configFile = "sing-box-client/config.json";
  configFilePath = config.sops.templates."${configFile}".path;
in {

  sops-keys = [
    "main-password"
    "sing-box/server/address"
    "sing-box/shadowtls/server_name"
  ];

  sops.templates."${configFile}" = {
    content = builtins.readFile ./templates/config.json;
    mode = "0400";
  };

  systemd.packages = [ pkgs.sing-box-prebuilt ];
  systemd.services.sing-box = {
    path = with pkgs; [ iproute2 nftables bash ];
    preStart = ''
      echo "working directory: $(pwd)"
      echo "RUNTIME_DIRECTORY: $RUNTIME_DIRECTORY"
      rm -f ''${STATE_DIRECTORY}/rule_exts;
      ln -sf ${./templates/rule_exts} $STATE_DIRECTORY/rule_exts
      #rm -f $RUNTIME_DIRECTORY/config.json
      #ln -sf ${configFilePath} $RUNTIME_DIRECTORY/config.json
    '';
    postStart = ''
      # setup route and nftables
      ${./scripts/intercept.sh} start
    '';
    serviceConfig = {
      StateDirectory = "sing-box";
      StateDirectoryMode = "0700";
      RuntimeDirectory = "sing-box";
      RuntimeDirectoryMode = "0700";
      ExecStart = [
        ""
        "${
          lib.getExe pkgs.sing-box-prebuilt
        } -D \${STATE_DIRECTORY} -C \${RUNTIME_DIRECTORY} run -c ${configFilePath}"
      ];
    };
    preStop = ''
      ${./scripts/intercept.sh} stop
    '';
    postStop = ''
      #TODO notify mosdns forwarding dns query to outside
    '';
    wantedBy = [ "multi-user.target" ];
  };

}
