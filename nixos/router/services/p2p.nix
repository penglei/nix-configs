{ config, lib, pkgs, ... }:
let cfg = config;
in {
  services.transmission = {
    enable = lib.mkDefault false;
    webHome = pkgs.flood-for-transmission;
  };

  imports = [

    {
      config = lib.mkIf cfg.services.flood.enable {
        environment.systemPackages = [ pkgs.mediainfo ];
        systemd.services.flood = { path = with pkgs; [ mediainfo ]; };
      };
    }

    {
      services.flood = {
        enable = lib.mkDefault false;
        openFirewall = true;
        host = "::";
      };
    }

  ];
}
