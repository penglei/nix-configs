{ config, pkgs, hostname, ... }: {
  imports = [
    ./network/interface.nix
    ./network/netaddr.nix
    ./network/firewall.nix
    ./network/nat.nix
    ./services/dhcpcd-pd.nix # 从wan申请pd并配置给br-lan

    #{
    ./services/kea.nix # dhcpv4
    ./services/radvd.nix # ra服务，通过br-lan在局域网内广播ra消息
    ./services/mosdns.nix # dns

    ./services/dnsmasq.nix # dnsmasq可以同时提供: dhcpv4, ra, dns
    #}

    ./services/pppoe.nix
    ./services/pppoe-hooks.nix
    ./services/miniupnpd.nix

    ./services/sing-box.nix
    ./services/vpn-tailscale.nix
    ./services/p2p.nix
    ./services/vpn-netbird.nix
    ./services/ddns.nix
  ];

  environment.systemPackages = with pkgs; [ tcpdump bottom htop ];

  #this also enable 'services.resolved', see also 'nixos/modules/system/boot/networkd.nix'.
  systemd.network.enable = true;

  #disable network scripting configuration
  #https://wiki.nixos.org/wiki/Systemd/networkd
  #https://www.reddit.com/r/NixOS/comments/1fwh4f0/networkinginterfaces_vs_systemdnetworknetworks/
  networking = {
    useNetworkd = true;
    useDHCP = false;
    nftables.enable = true;
  };

  networking = {
    #dhcpcd.enable = true; #for router, we diable it
    #resolvconf.enable = true; #enabled by services.resolved 
    #useDHCP = true; #for router, we disable it
    hostName = hostname;
  };

  # services.resolved.enable = false;
  networking.nameservers =
    [ config.netaddr.ipv4.dns ]; # configure nameservers manually

  services.resolved = {
    #disable llmnr
    llmnr = "false";
    #disable mdns
    extraConfig = ''
      MulticastDNS=false
    '';
    # domain = ".";
  };

  systemd.services."systemd-networkd" = {
    environment.SYSTEMD_LOG_LEVEL = "debug";
  };
}
