{ config, pkgs, ... }: {

  services.networkd-dispatcher = {
    enable = true;
    rules."restart-tor" = {
      onState = [ "routable" "off" ];
      script = ''
        #!${pkgs.runtimeShell}
        if [[ $IFACE == ${config.netaddr.ipv4.wan.name} && $AdministrativeState == "configured" ]]; then
          echo "Restarting Tor ..."
          #systemctl restart tor
        fi
        exit 0
      '';
    };
  };
}
