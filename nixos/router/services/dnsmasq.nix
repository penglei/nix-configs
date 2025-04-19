{ config, ... }:
let deviface = "br-lan";
in {
  services.dnsmasq = {
    enable = false;
    settings = {
      interface = deviface;
      bind-interfaces = true; # Only bind to the specified interface

      # Should be set when dnsmasq is definitely the only DHCP server on a network
      dhcp-authoritative = false;

      # Upstream dns servers to which requests should be forwarded
      # debug upstream: dig +noedns +nocookie +retry=0 @127.0.0.1 -p 29753 www.google.com
      server = [ "127.0.0.1#29753" ];

      dhcp-host = [
        "56:9b:f1:15:cb:90,192.168.101.1,${config.networking.hostName},infinite"
      ];

      dhcp-option = [
        # Address of the gateway, i.e. your router
        "option:router,${config.netaddr.ipv4.gateway}"
      ];

      dhcp-range = with config.netaddr.ipv4.subnet.dhcp_pools; [
        # Range of IPv4 addresses to give out
        # <range start>,<range end>,<lease time>
        "${start},${end},24h"
        # Enable stateless IPv6 allocation
        "::f,::ff,constructor:${deviface},ra-stateless"
      ];

      dhcp-rapid-commit = true; # Faster DHCP negotiation for IPv6

      no-resolv = true;

      # Accept DNS queries only from hosts whose address is on a local subnet
      local-service = true;

      log-queries = true; # Log results of all DNS queries

      # Don't forward requests for the local address ranges (192.168.x.x etc) to upstream nameservers
      bogus-priv = true;

      expand-hosts = true;

      # Don't forward requests without dots or domain parts to upstream nameservers
      domain-needed = true;

      local = "/lan/";
      domain = "lan";

      dnssec = true; # Enable DNSSEC
      # DNSSEC trust anchor. Source: https://data.iana.org/root-anchors/root-anchors.xml
      trust-anchor =
        ".,20326,8,2,E06D44B80B8F1D39A95C0B0D7C65D08458E880409BBC683457104237C7F8EC8D";
    };
  };
}

