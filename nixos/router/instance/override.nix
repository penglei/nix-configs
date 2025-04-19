{ lib, ... }:
let False = lib.mkForce false;
in {
  services.kea.dhcp4.enable = False;
  services.radvd.enable = False;
  systemd.services.mosdns.enable = False;

  systemd.services.ddns-go.enable = False;
}
