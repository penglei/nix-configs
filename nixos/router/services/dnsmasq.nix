{ config, lib, ... }:
let
  deviface = "br-lan";
  ipv4-addrs = config.netaddr.ipv4.subnet.reservations;
  cfg = config.services.dnsmasq;

in {
  imports = [

    ({
      config = lib.mkIf cfg.enable {
        systemd.services.dnsmasq = {
          wants = [ "network-online.target" ]; # delcare dependencies
          after = [ "network-online.target" ]; # start order
          requires = [ "sys-subsystem-net-devices-br-lan.device" ];
          preStart = ''
            #/var/lib/$STATE_DIRECTORY/tftp

            mkdir -p /var/lib/dnsmasq/tftp
            chown dnsmasq /var/lib/dnsmasq/tftp
          '';
        };
      };
    })

  ];

  services.dnsmasq = {
    enable = lib.mkDefault false;

    # don't serve on local(127.0.0.1), which would modify 'networking.nameservers'
    resolveLocalQueries = false;

    settings = {
      interface = deviface;
      bind-interfaces = true; # Only bind to the specified interface

      log-queries = false; # "extra"; # Log results of all DNS queries
      log-dhcp = false;

      # Should be set when dnsmasq is definitely the only DHCP server on a network
      dhcp-authoritative = false;

      # `$cidr1,$cidr2` for IPv4 and IPv6 requestors.
      # chinadns-ng upstream doesn't support resolving ipv6 with ipv4 subnet
      add-subnet = "222.210.108.0/20,240e:39f:9:e88b::1/56";

      # Upstream dns servers to which requests should be forwarded
      # debug upstream: dig +noedns +nocookie +retry=0 @127.0.0.1 -p 29753 www.google.com
      server = [
        #"127.0.0.1#29753" #sing-box
        "127.0.0.1#5353" # chinadns
      ];

      dhcp-host = map (v4addr:
        # e.g. "74:e6:e2:fc:e3:2e,192.168.101.199,idrac,infinite"
        "${v4addr.hw-address},${v4addr.ip-address},${v4addr.hostname},infinite")
        ipv4-addrs;

      local = "/lan/"; # .lan domain is local(won't forward to upstream)
      domain = "lan"; # support short hostname as dns record

      expand-hosts = true;
      address = [
        "/ganger.lan/192.168.101.100"
        "/${config.networking.hostName}.lan/${config.netaddr.ipv4.gateway}"
      ];

      dhcp-match = [
        "set:efi-x86_64,option:client-arch,7"
        "set:efi-x86_64,option:client-arch,9"
        "set:bios,option:client-arch,0"
      ];
      dhcp-boot = [
        #https://netboot.xyz/downloads
        ''tag:ipxe,"netboot.xyz.kpxe"''
        ''tag:!ipxe,tag:bios,"netboot.xyz.efi"''
      ];
      enable-tftp = true;
      tftp-root = "/var/lib/dnsmasq/tftp";

      dhcp-option = [
        #Gateway address, i.e. your router
        "option:router,${config.netaddr.ipv4.gateway}"

        #Send a literal IP address as TFTP server name
        ''66,"${config.netaddr.ipv4.gateway}"''
      ];

      dhcp-range = with config.netaddr.ipv4.subnet.dhcp_pools; [
        # Range of IPv4 addresses to give out
        # <range start>,<range end>,<lease time>
        "${start},${end},24h"

        # Enable stateless IPv6 allocation
        # > ra-stateless sends router advertisements with the O and A bits set, and provides a stateless DHCP service.
        # > The client will use a SLAAC address, and use DHCP for other configuration information.
        "::,constructor:${deviface},ra-stateless"
      ];
      # enable-ra = true;
      # ra-param = "br-lan,60";

      dhcp-rapid-commit = true; # Faster DHCP negotiation for IPv4

      no-hosts = true; # don't read /etc/hosts
      no-resolv = true; # don't read /etc/resolv.conf as upstream

      # Accept DNS queries only from hosts whose address is on a local subnet
      local-service = true;

      # Don't forward requests for the local address ranges (192.168.x.x etc) to upstream nameservers
      bogus-priv = true;

      # Don't forward requests without dots or domain parts to upstream nameservers
      domain-needed = true;

      dnssec = false; # Enable DNSSEC
      # DNSSEC trust anchor. Source: https://data.iana.org/root-anchors/root-anchors.xml
      trust-anchor =
        ".,20326,8,2,E06D44B80B8F1D39A95C0B0D7C65D08458E880409BBC683457104237C7F8EC8D";
    };
  };
}

