{ config, pkgs, lib, ... }:
let
  secrets.pppoe = {
    username = config.sops.placeholder."pppoe.username";
    password = config.sops.placeholder."pppoe.password";
  };
  cdnetCfg = "ppp/peers/cdnet";
in {
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
      cdnet = {
        autostart = true;
        enable = true;
        config = ""; # will be overrided below
      };
    };
  };
  environment.etc."${cdnetCfg}" =
    lib.mkForce { source = config.sops.templates."${cdnetCfg}".path; };
  sops.templates."${cdnetCfg}" = {
    content = ''
      nodetach      #don't fork to a daemon
      persist       #don't exit after a connection has been made
      maxfail 0
      holdoff 5     #wait 5 seconds to wait re-initiating the link after it terminates.

      plugin pppoe.so
      nic-eno1       #nic-xxx. N.B. 'nic-' prefix is used to forbid ambiguous of pppd option parsing.
      ifname pppoe-wan
      user "${secrets.pppoe.username}"
      password "${secrets.pppoe.password}"

      +ipv6
      mtu 1492
      mru 1492

      #?
      set AUTOIPV6=1
      set PEERDNS=0

      nodefaultroute    #don't add default route to system routing tables.
      usepeerdns        #env DNS1, DNS2 will be passed to callback hook script.
      ipparam thewan    #pass the string 'thewan' to callback hook script as 5th parameter.
    '';
    mode = "0400";
  };
}
