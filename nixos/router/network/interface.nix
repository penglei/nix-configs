# https://man.archlinux.org/man/systemd.network.5

{ config, ... }: {

  systemd.network.netdevs."01-br-wan" = {
    netdevConfig = {
      Name = "br-wan";
      Kind = "bridge";
    };
  };

  systemd.network.networks."01-br-wan" = {
    matchConfig.Name = "br-wan"; # The br-wan bridge must be up
    linkConfig = { ActivationPolicy = "up"; };
    networkConfig = { KeepMaster = true; };
  };

  systemd.network.netdevs."01-br-lan" = {
    netdevConfig = {
      Name = "br-lan";
      Kind = "bridge";
    };
  };

  systemd.network.networks."01-br-lan" = {
    matchConfig.Name = "br-lan";
    networkConfig = {
      #Address = [config.netaddr.ipv4.subnet.all];
      Address = [ "${config.netaddr.ipv4.router}/24" ];
      #Specifying a gateway would add a default route unexpectly,
      #which is conflict with router.
      # Gateway = config.netaddr.ipv4.gateway;

      #host-self is not a router, don't do work of router.
      #IPMasquerade = "ipv4";
      #IPv6SendRA = true;
      #IPv4Forwarding = true;
    };
    routes = [{
      Destination = config.netaddr.ipv4.subnet.all;
      # Gateway = config.netaddr.ipv4.gateway;
      Metric = 1024;
    }];
    #linkConfig.RequiredForOnline = "routable";
  };

  systemd.network.networks = {
    # prefix "00" is less than "01-br-wan", which can override br-wan configuration
    "00-ops" = {
      matchConfig.Name = "br-wan";
      networkConfig = {
        DHCP = "ipv4"; # currently, it's in ops network (192.168.1.0/24)
      };
      dhcpV4Config = {
        UseDNS = false;
        UseRoutes = true;
        UseGateway = false;
      };
    };
  };

  #❯ ip route list table all
  systemd.network.config.routeTables = { custom = 200; };

}

############# vlan demo #############
# # /etc/systemd/network/25-bridge-slave-interface-1.network
# [Match]
# Name=enp3s0
#
# [Network]
# Bridge=bridge0
#
# [BridgeVLAN]
# VLAN=1-32
# PVID=42
# EgressUntagged=42
#
# [BridgeVLAN]
# VLAN=100-200
#
# [BridgeVLAN]
# EgressUntagged=300-400
