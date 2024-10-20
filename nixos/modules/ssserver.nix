{ pkgs, lib, config, ... }:

let
  #configFile = config.sops.templates.ssserver.path;
  configFile = config.sops.secrets."ssserver.json".path;
in {

  sops.secrets."ssserver.json" = {
    sopsFile = ../../secrets/server.yaml;
    restartUnits = [ "ssserver.service" ];
    templates.ssserver.content = builtins.toJSON { "server_port" = 8388; };
  };
  systemd.services.ssserver = {
    description = "ssserver daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.shadowsocks-rust pkgs.v2ray-plugin ];
    script = ''
      exec ssserver -c ${configFile}
    '';
    serviceConfig = { WorkingDirectory = "/tmp"; };
  };
}
