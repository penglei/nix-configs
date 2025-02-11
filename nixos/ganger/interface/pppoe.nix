{ config, pkgs, lib, ... }:
let
  provider = "cdnet";
  cdnetCfg = "ppp/peers/${provider}";
  ifname = "eno1";
in {
  imports = [ ./pppd-hooks.nix ];

  #declare required secret keys
  sops-keys = [ "network/pppoe/username" "network/pppoe/password" ];

  environment.systemPackages = with pkgs; [ ppp ];
  boot.kernel = {
    sysctl = {
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv6.conf.all.forwarding" = true;
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
      nic-${ifname}       #nic-xxx. N.B. 'nic-' prefix is used to prevent be ambiguous for pppd option parsing.
      ifname pppoe-wan

      user "${config.sops.placeholder."network/pppoe/username"}"
      password "${config.sops.placeholder."network/pppoe/password"}"
      #file ... #TODO read auth from a separate file.

      +ipv6
      mtu 1492
      mru 1492

      #?
      set AUTOIPV6=1
      set PEERDNS=0

      nodefaultroute    #don't add default route.
      usepeerdns        #env DNS1, DNS2 will be passed to callback hook script.
      ipparam thewan    #pass the string 'thewan' to callback hook script as 5th parameter.
    '';

    mode = "0400";
  };
}
