{ config, pkgs, ... }:

let lease_file = "/var/lib/miniupnpd/upnp.leases";
in {
  environment.systemPackages = [ pkgs.miniupnpc ];
  services.miniupnpd = {
    enable = true;
    externalInterface = config.netaddr.iface.wan.name;
    internalIPs = [ "br-lan" ];
    natpmp = true;
    appendConfig = ''
      uuid=bdbf76d0-7ed9-4589-841a-57db9f7ffe12

      lease_file=${lease_file}

      bitrate_down=8388608
      bitrate_up=4194304

      upnp_table_name=miniupnpd
      upnp_nat_table_name=miniupnpd

      ipv6_disable=yes
      secure_mode=no
      system_uptime=yes

      allow 1024-65535 ${config.netaddr.ipv4.subnet.all} 1024-65535
      deny 0-65535 0.0.0.0/0 0-65535
    '';
    #package default derivation:
    #"configureFlags": "--firewall=iptables --ipv6 --leasefile --regex --vendorcfg --portinuse"
    # package = "";
  };

  systemd.services.miniupnpd = {
    wants = [ "network-online.target" ];
    preStart = ''
      mkdir -p /var/lib/miniupnpd/
      touch ${lease_file}
    '';
    #serviceconfig.ExecStart = "miniupnpd -d -vv -f miniupnpd.conf";
  };
}
