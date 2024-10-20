{ pkgs, config, ... }:

let
  configFile = config.sops.secrets."ssserver.json".path;
  generatedConfigFile = config.sops.templates."ss-server-config.json".path;
  configTemplate = ''
    {
      "server": "0.0.0.0",
      "server_port": 80,
      "method" : "chacha20-ietf-poly1305",
      "password": "${config.sops.placeholder.ss-password}"
      "timeout" : 300
    }
  '';
in {
  sops.templates."ss-server-config.json" = {
    content = configTemplate;
    mode = "0400";
  };

  sops.secrets = let sfile = ../../secrets/server.yaml;
  in {
    "ssserver.json" = {
      sopsFile = sfile;
      restartUnits = [ "ssserver.service" ];
    };
    "ss-password" = { sopsFile = sfile; };
  };
  systemd.services.ssserver = {
    description = "ssserver daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.shadowsocks-rust pkgs.v2ray-plugin ];
    script = ''
      echo "sops template example file: ${generatedConfigFile} "
      exec ssserver -c ${configFile}
    '';
    serviceConfig = { WorkingDirectory = "/tmp"; };
  };
}
