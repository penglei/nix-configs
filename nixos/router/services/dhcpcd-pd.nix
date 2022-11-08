# dhcpcd-pd(Prefix Delegation)，整个配置是从dhcpcd简化而来: 只处理ipv6 pd
{ config, lib, pkgs, ... }:

let
  dhcpcdConf = pkgs.writeText "dhcpcd-pd.conf" ''
    #Generate a RFC 4361 compliant DHCP Unique Identifier
    duid

    #Disable routing solicitation defautly
    noipv6rs

    #We only want to handle IPv6 with dhcpcd, the IPv4 is still done through pppd daemon
    ipv6only

    #Wait for an ipv6 address to be assigned before forking to the background
    waitip 6

    #Don't run these hook scripts.
    #  > resolv.conf: don't touch our DNS settings
    nohook resolv.conf, yp, hostname, ntp

    option rapid_commit

    #Selects the interface identifier used for SLAAC generated IPv6 addresses.
    #  If private is used, a RFC 7217 address is generated.
    #  If token is used then the token is combined with the prefix to make the final address.
    #  The temporary directive will create a temporary address for the prefix as well.
    slaac private

    #Request pd from the interface
    interface ${config.netaddr.iface.wan.name}
      # # Enable routing solicitation for current interface(we have disable sa defaultly above)
      ipv6rs

      ## Set the Interface Association Identifier to iaid.
      ## (This option must be used in an interface block).
      iaid 1

      ##Request a DHCPv6 Normal Address for iaid. iaid defaults to the iaid option as described above.
      #ia_na

      ##ia_pd means "Identity Association for Prefix Delegation".
      ##Request a DHCPv6 Delegated Prefix for iaid. This option must be used in an interface block.
      ##  The below line requests a PD and assign it to multiple VLANs' interface, `2` is a new iaid that
      ##  can distinct from others.
      #ia_pd 2 eth0/1/64 eth0.12/12/64 eth0.20/20/64 eth0.34/34/64 # request prefixes for multiple VLANs

      #Request a PD and assign to interface
      # ia_pd 2/::/60 br-lan/0
      ia_pd 1 br-lan
  '';
in {

  environment.systemPackages = [ pkgs.dhcpcd ];

  systemd.services.dhcpcd-pd = {
    enable = lib.mkDefault true;
    description = "DHCP Client configured for ipv6 only";

    wantedBy = [
      "multi-user.target"
      "network-online.target" # no default gateway
    ];
    wants = [ "network.target" "resolvconf.service" ];
    after = [ "resolvconf.service" ];
    before = [ "network-online.target" ];

    # restartTriggers = [ cfg.runHook ];

    # Stopping dhcpcd during a reconfiguration is undesirable
    # because it brings down the network interfaces configured by
    # dhcpcd.  So do a "systemctl restart" instead.
    stopIfChanged = false;

    path = [ pkgs.dhcpcd pkgs.nettools pkgs.systemd ];

    unitConfig.ConditionCapability = "CAP_NET_ADMIN";

    serviceConfig = {
      Type = "forking";
      PIDFile = "/run/dhcpcd/pid";
      User = "dhcpcd";
      Group = "dhcpcd";
      StateDirectory = "dhcpcd";
      RuntimeDirectory = "dhcpcd";

      #--persistent: Do not remove interface configuration on shutdown.
      ExecStart =
        "@${pkgs.dhcpcd}/sbin/dhcpcd dhcpcd --quiet --persistent --config ${dhcpcdConf}";
      ExecReload = "${pkgs.dhcpcd}/sbin/dhcpcd --rebind";
      Restart = "always";
      AmbientCapabilities =
        [ "CAP_NET_ADMIN" "CAP_NET_RAW" "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet =
        [ "CAP_NET_ADMIN" "CAP_NET_RAW" "CAP_NET_BIND_SERVICE" ];
      ReadWritePaths = [ "/proc/sys/net/ipv4" "/proc/sys/net/ipv6" ];
      DeviceAllow = "";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges =
        lib.mkDefault true; # may be disabled for sudo in runHook
      PrivateDevices = true;
      PrivateMounts = true;
      PrivateTmp = true;
      PrivateUsers = false;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome =
        "tmpfs"; # allow exceptions to be added to ReadOnlyPaths, etc.
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = "strict";
      RemoveIPC = true;
      RestrictAddressFamilies =
        [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" "AF_PACKET" ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallFilter = [
        "@system-service"
        "~@aio"
        "~@keyring"
        "~@memlock"
        "~@mount"
        "~@privileged"
        "~@resources"
      ];
      SystemCallArchitectures = "native";
      UMask = "0027";
    };
  };

  users.users.dhcpcd = {
    isSystemUser = true;
    group = "dhcpcd";
  };
  users.groups.dhcpcd = { };

}
