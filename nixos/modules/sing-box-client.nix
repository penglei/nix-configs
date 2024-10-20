{ pkgs, config, lib, ... }:
let
  base64 = import ../../utils/base64.nix lib;
  cfg = {
    inbounds = [{
      type = "socks";
      listen = "0.0.0.0";
      listen_port = 18283;
      sniff = true;
      sniff_override_destination = true;
      domain_strategy = "ipv4_only"; # work with chinadns-ng
      tag = "socks-in";
      users = [ ];
    }];

    outbounds = [
      {
        type = "shadowsocks";
        tag = "ss";
        detour = "shadowtls-out";
        method = "2022-blake3-aes-128-gcm";
        password = base64.encode config.sops.placeholder."secret.main.password";
      }

      {
        type = "shadowtls";
        tag = "shadowtls-out";
        server = config.sops.placeholder."sing-box.server.address";
        server_port = 443;
        version = 3;
        password = base64.encode config.sops.placeholder."secret.main.password";
        tls = {
          enabled = true;
          server_name =
            config.sops.placeholder."sing-box.shadowtls.server_name";
        };
      }
    ];
  };
  sopsDescrypt = keys:
    lib.foldl
    (acc: key: acc // { "${key}" = { sopsFile = ../../secrets/server.yaml; }; })
    { } keys;

  ## Not recommanded: sensitive data is stored in /nix/store, which everyone can read.
  # configFile = pkgs.writeText "config.json" (builtins.toJSON cfg); 
  configFile = config.sops.templates."config.json".path;

in {

  sops.secrets = sopsDescrypt [
    "secret.main.password"
    "sing-box.server.address"
    "sing-box.shadowtls.server_name"
  ];
  sops.templates."config.json" = {
    content = builtins.toJSON cfg;
    mode = "0400";
  };

  systemd.services.sing-box = {
    description = "sing-box client daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.sing-box ];
    script = "exec sing-box -c ${configFile}";
    serviceConfig = { WorkingDirectory = "/tmp"; };
  };
}
