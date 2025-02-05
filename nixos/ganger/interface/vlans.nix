# this module is not employed. Ganger has multiple network interfaces, so we don't need vlan.
{
  systemd.network.netdevs."20-eno1.1195.wan" = {
    netdevConfig = {
      Name = "wan";
      Kind = "vlan";
    };
    vlanConfig = { Id = 1195; };
  };
}
