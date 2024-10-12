{ lib, config, ... }:

{
  imports = [ ../basic ../modules/ssserver.nix ];

  networking.firewall.enable = false;

  sops = {
    defaultSopsFile = ../../secrets/basic.yaml;
    secrets."resolver-key.pem" = {
      sopsFile = ../../secrets/server.yaml;
      restartUnits = [ "dnscrypt-proxy2.service" ];
    };
    secrets."ssserver.json" = {
      sopsFile = ../../secrets/server.yaml;
      restartUnits = [ "ssserver.service" ];
    };

    templates.ssserver.content = builtins.toJSON { "server_port" = 8388; };
  };

  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      server_names = [ "cloudflare-security" ];
      static = {
        "static.cloudflare-security" = {
          stamp =
            "sdns://AgMAAAAAAAAABzEuMC4wLjIAG3NlY3VyaXR5LmNsb3VkZmxhcmUtZG5zLmNvbQovZG5zLXF1ZXJ5";
        };
      };
      local_doh = {
        listen_addresses = [ "0.0.0.0:443" ];
        path = "/dns-query";
        cert_file = ../../certs/resolver.pem;
        cert_key_file = config.sops.secrets."resolver-key.pem".path;
      };
    };
  };
  systemd.services.dnscrypt-proxy2 = {
    serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "root";
      Group = "root";
    };
  };

}
