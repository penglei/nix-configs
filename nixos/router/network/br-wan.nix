{
  systemd.network.netdevs."01-br-wan" = {
    netdevConfig = {
      Name = "br-wan";
      Kind = "bridge";
    };
  };
}

