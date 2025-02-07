{ config, ... }:

let utils = (import ./utils.nix);
in {
  systemd.network.networks."10-lan-vms" = {
    matchConfig.Name = [ "vm-*" ];
    networkConfig = { Bridge = "br-lan"; };
  };

  systemd.network.netdevs."br-lan" = {
    netdevConfig = {
      Name = "br-lan";
      Kind = "bridge";
    };
  };
  systemd.network.networks."10-lan-bridge" = {
    matchConfig.Name = "br-lan";
    networkConfig = {
      Address = [ "192.168.202.1/24" "2001:db8::a/64" ];
      # Gateway = "192.168.202.1"; #don't specify gateway which would add a default route.
      #DNS = [ "192.168.101.1" ];
      # IPv6AcceptRA = true;
      IPMasquerade = "ipv4";
      IPv4Forwarding = true;
    };
    #linkConfig.RequiredForOnline = "routable";
  };

  microvm.vms."lan-vm-1" = {
    config = {
      microvm = {
        mem = 8192;
        vcpu = 4;

        shares = [{
          source = "/nix/store";
          mountPoint = "/nix/.ro-store";
          tag = "rs-store";
          proto = "virtiofs";
        }];
        hypervisor = "cloud-hypervisor";

        interfaces = [(rec {
          type = "tap";
          id = "vm-1";
          mac = utils.gen_mac id;
        })
        # (rec {
        #   type = "tap";
        #   id = "vm-wan";
        #   mac = utils.gen_mac id;
        # })
          ];
      };

      imports = [
        ../../modules/programs.nix
        {
          nix.settings = {
            experimental-features =
              [ "nix-command" "flakes" "auto-allocate-uids" "cgroups" ];
          };
        }
      ];
      system.stateVersion = config.system.nixos.version;

      users.users.root.password = "toor";
      services.openssh = {
        enable = true;
        settings.PermitRootLogin = "yes";
      };

      systemd.network.enable = true;
      systemd.network.networks."20-lan" = {
        matchConfig.Type = "ether";
        networkConfig = {
          Address = [ "192.168.202.2/24" "2001:db8::b/64" ];
          Gateway = "192.168.202.1";
          DNS = [ "192.168.101.1" ];
          IPv6AcceptRA = true;
          DHCP = "no";
        };
      };
    };
  };
}
