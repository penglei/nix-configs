{ pkgs, config, ... }:
let
  passwordstub = config.sops.placeholder."secret.main.password";
  cfg = {
    inbounds = [
      {
        type = "shadowtls";
        listen = "::";
        listen_port = 443;
        detour = "shadowsocks-in";
        version = 3;
        users = [{ password = passwordstub; }];
        handshake = {
          server = config.sops.placeholder."sing-box.shadowtls.server_name";
          server_port = 443;
        };
        strict_mode = true;
      }

      {
        type = "shadowsocks";
        tag = "shadowsocks-in";
        listen = "127.0.0.1";
        method = "2022-blake3-aes-128-gcm";
        password = passwordstub;
        multiplex = { enabled = true; };
      }
    ];

    outbounds = [{ type = "direct"; }];
  };

  ## Not recommanded: sensitive data is stored in /nix/store, which everyone can read.
  # configFilePath = pkgs.writeText "config.json" (builtins.toJSON cfg); 
  configFile = "sing-box-client/config.json";
  configFilePath = config.sops.templates."${configFile}".path;

in {
  imports = [ ../../secrets ];

  sops.templates."${configFile}" = {
    content = builtins.toJSON cfg;
    mode = "0400";
  };

  systemd.services.sing-box = {
    description = "sing-box server daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.sing-box ];
    script = "exec sing-box run -c ${configFilePath}";
    serviceConfig = { WorkingDirectory = "/tmp"; };
  };
}

