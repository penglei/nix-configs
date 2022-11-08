{ config, pkgs, lib, ... }:
let
  peerCfgName = "pppoe";
  peerCfgFile = "ppp/peers/${peerCfgName}";

in {
  imports = [ ./pppoe-hooks.nix ];

  #declare required secret keys
  sops-keys = [ "network/pppoe/username" "network/pppoe/password" ];

  environment.systemPackages = with pkgs; [ ppp ];
  boot.kernel = {
    sysctl = {
      "net.ipv4.conf.all.forwarding" = true;

      "net.ipv6.conf.all.forwarding" = true;
      # enable kernel slaac automatically
      # "net.ipv6.conf.all.accept_ra" = 2;
      # "net.ipv6.conf.default.accept_ra" = 2;
      "net.ipv6.conf.all.accept_ra" = 1;
      "net.ipv6.conf.default.accept_ra" = 1;
    };
  };

  services.pppd = {
    enable = true;
    peers = {
      "${peerCfgName}" = {
        autostart = true;
        enable = true;
        config = "#should be overrided!"; # will be overrided below
      };
    };
  };
  systemd.services."pppd-${peerCfgName}" = {
    preStart = ''
      mkdir -p /var/lib/pppoe
    '';
    postStop = let f = "/var/lib/pppoe/dns-servers";
    in ''
      if [ -f "${f}" ]; then
        rm "${f}"
      fi
    '';
    serviceConfig = {
      PrivateMounts = lib.mkForce false;
      PrivateTmp = lib.mkForce false;
      ProtectHome = lib.mkForce false;
      ProtectSystem = lib.mkForce false;
    };
  };
  environment.etc = {
    "${peerCfgFile}" =
      lib.mkForce { source = config.sops.templates."${peerCfgFile}".path; };
  };

  sops.templates."${peerCfgFile}" = {
    content = ''
      #docs: https://man.cx/pppd(1)

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

      +ipv6 #Enable IPv6 and IPv6CP without specifying interface identifiers.
      ##Pv6控制协议（IPv6CP）是一种网络控制协议。IPv6CP主要负责在点对点链路终端双方上配置，可用及停用IPv6协议模块，可协商的参数包括接口ID和IPv6压缩协议。
      ##IPv6CP使用与链路控制协议（LCP）相同的包交换机制。但只有在PPP达到网络层协议阶段时，IPv6CP包才可以被交换。在达到这种阶段前接收的IPv6CP包需要被丢弃。
      ##目前，IPv6CP协商的选项只支持接口ID的协商，不支持IPv6压缩协议的协商。IPv6网络中，PPP用户与IPoE用户都需要使用ND协议或DHCPv6协议完成全球单播地址和
      ##配置信息的分配，使用DHCPv6协议的IA_PD选项完成CPE路由模式下LAN口IPv6前缀的分配。

      ipv6cp-use-persistent #Use uniquely-available persistent value for link local address.

      mtu 1492
      mru 1492

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
      ipparam thewan    #pass the string 'thewan' as the last parameter to hook script.
    '';

    mode = "0400";
  };
}
