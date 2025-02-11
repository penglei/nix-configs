{ pkgs, config, ... }:
let
  passwordstub = config.sops.placeholder."main-password";
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
          server = config.sops.placeholder."sing-box/shadowtls/server_name";
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

  #This approach is not recommended, as `pkg.writeText` will store sensitive data in `/nix/store`, which is accessible to everyone.
  # configFilePath = pkgs.writeText "config.json" (builtins.toJSON cfg); 

  configFile = "sing-box-client/config.json";
  configFilePath = config.sops.templates."${configFile}".path;

in {
  imports = [ ../../secrets ];
  sops-keys = [ "sing-box/shadowtls/server_name" ];

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

