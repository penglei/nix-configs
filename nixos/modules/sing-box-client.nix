{ pkgs, config, ... }:
let
  passwordstub = config.sops.placeholder."secret.main.password";
  cfg = {
    inbounds = [
      {
        type = "mixed";
        listen = "::";
        listen_port = 10000;
      }

      {
        type = "socks";
        listen = "0.0.0.0";
        listen_port = 18283;
        sniff = true;
        sniff_override_destination = true;
        domain_strategy = "ipv4_only"; # work with chinadns-ng
      }
    ];

    outbounds = [
      {
        type = "shadowsocks";
        detour = "shadowtls-out";
        method = "2022-blake3-aes-128-gcm";
        password = passwordstub;
        multiplex = { enabled = true; };
      }

      {
        type = "shadowtls";
        tag = "shadowtls-out";
        server = config.sops.placeholder."sing-box.server.address";
        server_port = 443;
        version = 3;
        password = passwordstub;
        tls = {
          enabled = true;
          server_name =
            config.sops.placeholder."sing-box.shadowtls.server_name";
          utls = {
            enabled = true;
            fingerprint = "chrome";
          };
        };
      }
    ];
  };

  #This approach is not recommended, as `pkg.writeText` will store sensitive data in `/nix/store`, which is accessible to everyone.
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
    description = "sing-box client daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.sing-box ];
    script = "exec sing-box run -c ${configFilePath}";
    serviceConfig = { WorkingDirectory = "/tmp"; };
  };
}
