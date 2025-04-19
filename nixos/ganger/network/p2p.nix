{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.mediainfo ];
  services = {
    transmission = {
      enable = false;
      webHome = pkgs.flood-for-transmission;
    };
    flood = {
      enable = true;
      openFirewall = true;
      host = "::";
    };
  };
  systemd.services.flood = { path = with pkgs; [ mediainfo ]; };
}
