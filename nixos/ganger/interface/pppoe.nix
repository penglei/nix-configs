# ipv6 test:
#❯ curl https://6.ipw.cn/

{ config, pkgs, lib, ... }:
let
  provider = "cdnet";
  cdnetCfg = "ppp/peers/${provider}";

in {
  imports = [ ./pppd-hooks.nix ];

  #declare required secret keys
  sops-keys = [ "network/pppoe/username" "network/pppoe/password" ];

  environment.systemPackages = with pkgs; [ ppp ];
  boot.kernel = {
    sysctl = {
      "net.ipv4.conf.all.forwarding" = true;

      # enable forwarding ipv6 and kernel slaac
      "net.ipv6.conf.all.forwarding" = true;
      "net.ipv6.conf.all.accept_ra" = 2;
      "net.ipv6.conf.default.accept_ra" = 2;
    };
  };

  services.pppd = {
    enable = true;
    peers = {
      "${provider}" = {
        autostart = true;
        enable = true;
        config = "#should be overrided!"; # will be overrided below
      };
    };
  };
  systemd.services."pppd-${provider}" = {
    serviceConfig = {
      PrivateMounts = lib.mkForce false;
      PrivateTmp = lib.mkForce false;
      ProtectHome = lib.mkForce false;
      ProtectSystem = lib.mkForce false;
    };
  };
  environment.etc = {
    "${cdnetCfg}" =
      lib.mkForce { source = config.sops.templates."${cdnetCfg}".path; };
  };

  sops.templates."${cdnetCfg}" = {
    content = ''
      debug
      nodetach      #don't fork to a daemon
      persist       #don't exit after a connection has been made
      maxfail 0
      holdoff 5     #wait 5 seconds to wait re-initiating the link after it terminates.

      plugin pppoe.so
      nic-${config.netaddr.iface.wan.nic}       #nic-xxx. N.B. 'nic-' prefix is used to prevent be ambiguous for pppd option parsing.
      ifname ${config.netaddr.iface.wan.name}

      user "${config.sops.placeholder."network/pppoe/username"}"
      password "${config.sops.placeholder."network/pppoe/password"}"
      #file ... #Or read auth from a separate file.

      +ipv6
      ipv6cp-use-persistent
      ipv6cp-accept-local
      ipv6cp-accept-remote

      mtu 1492
      mru 1492

      set AUTOIPV6=1
      set PEERDNS=0

      ## Add a default IPv6 route to the system routing tables,
      ## using the peer as the gateway, when  IPv6CP  negotiation
      ## is  successfully  completed.This  entry is removed when
      ## the PPP connection is broken.  This option is privileged
      ## if the nodefaultroute6 option has been specified.
      ## WARNING: Do not enable this option by default.  IPv6 routing tables
      ## are managed by kernel (as apposite to IPv4) and IPv6 default route
      ## is config‐ured by kernel automatically too based on ICMPv6 Router Advertisement packets.
      ## This option may conflict with kernel IPv6 route setup and should be used only for broken IPv6 networks.
      #defaultroute6

      nodefaultroute    #don't add default route.
      usepeerdns        #env DNS1, DNS2 will be passed to callback hook script.
      ipparam thewan    #pass the string 'thewan' to callback hook script as 5th parameter.
    '';

    mode = "0400";
  };
}
