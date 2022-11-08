{ pkgs, config, ... }:

let
  configFilePath = config.sops.secrets."ssserver/config.json".path;
  generatedConfigFilePath = config.sops.templates."ssserver/config.json".path;
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
  sops.templates."ssserver/config.json" = {
    content = configTemplate;
    mode = "0400";
  };

  #declare secrets
  sops.secrets = let sfile = ../../secrets/secrets.yaml;
  in {
    "ssserver/config.json" = {
      sopsFile = sfile;
      restartUnits = [ "ssserver.service" ];
      key = "ssserver.json";
    };
    "ss-password" = {
      sopsFile = sfile;
      key = "main-password";
    };
  };
  systemd.services.ssserver = {
    description = "ssserver daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.shadowsocks-rust pkgs.v2ray-plugin ];
    script = ''
      echo "sops template example file: ${generatedConfigFilePath} "
      exec ssserver -c ${configFilePath}
    '';
    serviceConfig = { WorkingDirectory = "/tmp"; };
  };
}
