{ config, ... }:

let utils = (import ../utils.nix);
in {
  systemd.network.networks."10-lan-vms" = {
    matchConfig.Name = [ "vm-*" ];
    networkConfig = { Bridge = "br-lan"; };
  };

  microvm.vms."lan-vm-1" = {
    specialArgs = {
      username = "penglei";
      hostname = "lan-vm-1";
    };
    config = {
      microvm = {
        mem = 8192;
        vcpu = 4;

        shares = [
          {
            source = "/nix/store";
            mountPoint = "/nix/.ro-store";
            tag = "ro-store";
            proto = "virtiofs";
          }
          {
            source = "/persist/var/lib/microvms/lan-vm-1/shares";
            mountPoint = "/persist";
            tag = "persist";
            proto = "virtiofs";
          }
        ];
        hypervisor = "cloud-hypervisor";

        interfaces = [(rec {
          type = "tap";
          id = "vm-1";
          mac = utils.gen_mac id;
        })];
      };

      imports = [
        ../../modules/programs.nix
        ../../modules/configuration.nix
        ./writable-layer.nix
        {
          nix.settings = {
            experimental-features =
              [ "nix-command" "flakes" "auto-allocate-uids" "cgroups" ];
          };
        }
      ];

      system.activationScripts.ensure-persist-dir = {
        text = "mkdir -p /persist/{etc,opt/ssh}";
      };
      services.openssh.hostKeys = [
        {
          bits = 4096;
          path = "/persist/opt/ssh/ssh_host_rsa_key";
          type = "rsa";
        }
        {
          path = "/persist/opt/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
      # environment.etc.machine-id.source =
      #   pkgs.runCommandLocal "machine-id-link" { } ''
      #     ln -s /persist/etc/machine-id $out
      #   '';

      # users.users.root.password = "toor";
      services.openssh = {
        enable = true;
        # settings.PermitRootLogin = "yes";
      };

      networking = {
        useNetworkd = true;
        useDHCP = false;
        nftables.enable = true;
        wireless.enable = false;
      };
      services.resolved = {
        #disable llmnr
        llmnr = "false";
        #disable mdns
        extraConfig = ''
          MulticastDNS=false
        '';
      };

      systemd.network = {
        enable = true;
        networks."20-lan" = {
          matchConfig.Type = "ether";
          networkConfig = {
            #Address = [ "192.168.202.2/24" "2001:db8::b/64" ];
            #Gateway = "192.168.202.1";
            IPv6AcceptRA = true;
            DHCP = "ipv4";
          };
        };
      };
      system.stateVersion = config.system.nixos.version;
    };
  };
}
