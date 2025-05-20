{ pkgs, ... }: {
  systemd.services.keeping = {
    description = "Keep network connections alive";
    after = [ "network.target" ];
    path = with pkgs; [ bash iputils wireguard-tools ];
    wantedBy = [ "multi-user.target" ];
    # script = "";
    serviceConfig = {
      Restart = "always";
      RestartSec = 0;
      ExecStart = ../../scripts/keeping.sh;
    };
  };

}
