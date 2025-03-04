# "http://[USERNAME]:[PASSWORD]@ddns.oray.com/ph/update?hostname=[DOMAIN]&myip=[IP]"

{ pkgs, config, ... }: {
  systemd.services.ddns-go = {
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    description = "A simple, easy-to-use DDNS service";
    serviceConfig = {
      ExecStart = "${pkgs.ddns-go}/bin/ddns-go -c ${
          config.sops.templates."ddns-go.yaml".path
        } -noweb";
      Restart = "always";
      RestartSec = 120;
    };
    unitConfig = {
      StartLimitIntervalSec = 5;
      StartLimitBurst = 10;
    };
  };

  sops.templates."ddns-go.yaml".content = ''
    dnsconf:
    - ipv4:
        enable: true
        gettype: netInterface
        netinterface: ${config.netaddr.iface.wan.name}
        domains:
          - 160u61h456.iask.in
      dns:
        name: callback
        id: "http://${
          config.sops.placeholder."ddns/oray/auth"
        }@ddns.oray.com/ph/update?hostname=#{domain}&myip=#{ip}"
  '';

  sops-keys = [
    "ddns/oray/auth" # username:password
  ];
}

