{ lib, ... }: {
  systemd.services.dhcpcd-pd.enable = lib.mkForce false;
  services.kea.dhcp4.enable = lib.mkForce false;
}
