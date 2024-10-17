{ lib, config, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../nix.nix
    ../modules/configuration.nix
    ../modules/programs.nix
    ../modules/openssh.nix
    ../modules/pam.nix
    ../modules/ssserver.nix
  ];

  boot.initrd.availableKernelModules =
    [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.initrd.kernelModules = [ ];
  #boot.kernelModules = [ "kvm-intel" ]; #nested vm?
  boot.extraModulePackages = [ ];

  boot.loader = {
    grub.enable = true;
    grub.devices = [ "/dev/vda" ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

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

  system.stateVersion = "22.11";
}
