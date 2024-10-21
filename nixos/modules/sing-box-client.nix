{ pkgs, config, lib, ... }:
let
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
        password = config.sops.placeholder."secret.main.password";
      }

      {
        type = "shadowtls";
        tag = "shadowtls-out";
        server = config.sops.placeholder."sing-box.server.address";
        server_port = 443;
        version = 3;
        password = config.sops.placeholder."secret.main.password";
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
  configFile = config.sops.templates."sing-box-client/config.json".path;

in {

  sops.secrets = sopsDescrypt [
    "secret.main.password"
    "sing-box.server.address"
    "sing-box.shadowtls.server_name"
  ];
  sops.templates."sing-box-client/config.json" = {
    content = builtins.toJSON cfg;
    mode = "0400";
  };

  systemd.services.sing-box = {
    description = "sing-box client daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.sing-box ];
    script = "exec sing-box run -c ${configFile}";
    serviceConfig = { WorkingDirectory = "/tmp"; };
  };
}
