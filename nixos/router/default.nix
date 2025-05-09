{ config, pkgs, hostname, options, ... }: {
  imports = [
    ./network/interface.nix
    ./network/netaddr.nix
    ./network/firewall.nix
    ./network/nat.nix
    ./services/dhcpcd-pd.nix # 从wan申请pd并配置给br-lan

    ./services/nft-rules.nix

    #{
    ./services/kea.nix # dhcpv4
    ./services/radvd.nix # ra服务，通过br-lan在局域网内广播ra消息
    ./services/mosdns.nix # dns

    ./services/dnsmasq.nix # dnsmasq可以同时提供: dhcpv4, ra, dns
    #}

    ./services/pppoe.nix
    ./services/pppoe-hooks.nix
    ./services/miniupnpd.nix

    ./services/chinadns.nix
    ./services/sing-box.nix
    ./services/vpn-tailscale.nix
    ./services/p2p.nix
    ./services/vpn-netbird.nix
    ./services/ddns.nix
  ];

  environment.systemPackages = with pkgs; [ tcpdump iftop iotop bottom htop ];

  #disable network scripting configuration
  #https://wiki.nixos.org/wiki/Systemd/networkd
  #https://www.reddit.com/r/NixOS/comments/1fwh4f0/networkinginterfaces_vs_systemdnetworknetworks/
  networking = {
    hostName = hostname;

    useNetworkd = true;
    useDHCP = false;
    nftables.enable = true;

    timeServers = options.networking.timeServers.default
      ++ [ "ntp.ntsc.ac.cn" "ntp.aliyun.com" ];

    #diasble for router employed pppoe
    #useDHCP = true; #disable for router
    #dhcpcd.enable = true;

    #has enabled by services.resolved
    #resolvconf.enable = true;

    # configure nameservers manually
    nameservers = [ config.netaddr.ipv4.dns ];
    search = [ "lan" ];
  };

  #this also enable 'services.resolved', see also 'nixpkgs/nixos/modules/system/boot/networkd.nix'.
  systemd.network.enable = true;
  services.resolved = {

    #disable llmnr
    llmnr = "false";
    #disable mdns
    extraConfig = ''
      MulticastDNS=false
      ReadEtcHosts=no
    '';
    # domain = ".";
  };

  # services.ntp.enable = true;
  services.timesyncd.enable = true;

  systemd.services."systemd-networkd" = {
    environment.SYSTEMD_LOG_LEVEL = "debug";
  };
}
