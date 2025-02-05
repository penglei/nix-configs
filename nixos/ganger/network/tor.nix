{ pkgs, ... }: {

  services.networkd-dispatcher = {
    enable = true;
    rules."restart-tor" = {
      onState = [ "routable" "off" ];
      script = ''
        #!${pkgs.runtimeShell}
        if [[ $IFACE == "pppoe-wan" && $AdministrativeState == "configured" ]]; then
          echo "Restarting Tor ..."
          #systemctl restart tor
        fi
        exit 0
      '';
    };
  };
}
