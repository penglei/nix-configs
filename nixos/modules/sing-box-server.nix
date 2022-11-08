{ proxy_name }:
{ pkgs, config, ... }:
let
  passwordstub = config.sops.placeholder."main-password";
  cfg = {
    inbounds = [
      {
        type = "shadowtls";
        tag = "in-shadowtls";
        listen = "::";
        listen_port = 443;
        detour = "shadowsocks-inner";
        version = 3;
        users = [{ password = passwordstub; }];
        handshake = {
          server =
            config.sops.placeholder."sing-box/${proxy_name}/shadowtls/server_name";
          server_port = 443;
        };
        #strict_mode = true;
      }

      {
        type = "shadowsocks";
        tag = "shadowsocks-inner";
        method = "2022-blake3-aes-128-gcm";
        password = passwordstub;
        multiplex = { enabled = true; };
      }

      {
        type = "shadowsocks";
        tag = "in-ss";
        listen = "::";
        listen_port = 80;
        method = "2022-blake3-aes-128-gcm";
        password = passwordstub;
        network = "tcp";
      }
    ];

    outbounds = [{ type = "direct"; }];
  };

  #This approach is not recommended, as `pkg.writeText` will store sensitive data in `/nix/store`, which is accessible to everyone.
  # configFilePath = pkgs.writeText "config.json" (builtins.toJSON cfg); 

  configFile = "sing-box-server/config.json";
  configFilePath = config.sops.templates."${configFile}".path;

in {
  sops-keys =
    [ "main-password" "sing-box/${proxy_name}/shadowtls/server_name" ];

  sops.templates."${configFile}" = {
    content = builtins.toJSON cfg;
    mode = "0400";
  };

  environment.systemPackages = [ pkgs.sing-box-prebuilt ];

  systemd.services.sing-box = {
    description = "sing-box server daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.sing-box-prebuilt ];
    script = "exec sing-box run -c ${configFilePath}";
    serviceConfig = { WorkingDirectory = "/tmp"; };
  };
}

