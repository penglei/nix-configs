{ config, lib, ... }:

let routerAddr = config.netaddr.ipv4.router;
in {
  options = {
    netaddr = {
      ipv4 = lib.mkOption {
        type = lib.types.submodule {
          options = {
            router = lib.mkOption {
              type = lib.types.str;
              description = "IPv4 router address";
              # default = "192.168.101.1";
            };
            gateway = lib.mkOption {
              type = lib.types.str;
              default = routerAddr;
              description = "IPv4 gateway address (defaults to router)";
            };
            dns = lib.mkOption {
              type = lib.types.str;
              default = routerAddr;
              description = "IPv4 DNS server address (defaults to router)";
            };
            subnet = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  all = lib.mkOption {
                    type = lib.types.str;
                    description = "lan subnet cidr";
                  };
                  dhcp_pools = lib.mkOption {
                    type = lib.types.submodule {
                      options = {
                        start = lib.mkOption {
                          type = lib.types.str;
                          description = "dhcp allocatable range start";
                        };
                        end = lib.mkOption {
                          type = lib.types.str;
                          description = "dhcp allocatable range end";
                        };

                      };
                    };
                  };
                  reservations = lib.mkOption {
                    type = lib.types.listOf (lib.types.submodule {
                      options = {
                        hw-address = lib.mkOption {
                          type = lib.types.str;
                          description = "mac address";
                        };
                        ip-address = lib.mkOption {
                          type = lib.types.str;
                          description = "ipv4 address";
                        };
                        hostname = lib.mkOption {
                          type = lib.types.str;
                          description = "hostname";
                        };
                      };
                    });
                    default = [ ];
                  };
                };
              };
              description = "lan network config";
              default = { };
            };
          };
        };
        default = { };
      };
      ipv6 = lib.mkOption {
        type = lib.types.submodule {
          options = {
            router = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              description = "IPv6 ULA address";
              default = null;
            };
          };
        };
        default = { };
      };
      iface = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {
          wan.nic = "br-wan";
          wan.name = "pppoe-wan";
        };
      };
    };
  };
}

