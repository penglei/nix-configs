{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.mediainfo ];
  services = {
    transmission = {
      enable = false;
      webHome = pkgs.flood-for-transmission;
    };
    flood = {
      openFirewall = true;
      enable = true;
      host = "::";
    };
  };
  systemd.services.flood = { path = with pkgs; [ mediainfo ]; };
}
