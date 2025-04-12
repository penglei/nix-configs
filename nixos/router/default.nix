{ config, pkgs, ... }: {
  imports = [
    ./services/ddns.nix
    ./services/kea.nix
    ./services/mosdns.nix
    ./services/pppoe-hooks.nix
    ./services/radvd.nix
    ./services/sing-box.nix
    ./services/vpn-tailscale.nix
    ./services/dhcpcd-pd.nix
    ./services/miniupnpd.nix
    ./services/p2p.nix
    ./services/pppoe.nix
    ./services/vpn-netbird.nix

    ./network/br-lan.nix
    ./network/br-wan.nix
    ./network/netaddr.nix
    ./network/firewall.nix
    ./network/nat.nix
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
