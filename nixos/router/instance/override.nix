{ lib, ... }: {
  systemd.services.dhcpcd-pd.enable = lib.mkForce false;
  services.kea.dhcp4.enable = lib.mkForce false;
  systemd.services.ddns-go.enable = lib.mkForce false;
}
