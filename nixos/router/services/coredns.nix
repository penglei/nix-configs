{ lib, config, ... }: {
  services.coredns = {
    enable = lib.mkDefault false;
    config = ''
      . {
        bind ${config.netaddr.ipv4.dns}
        cache
        #forward to local chinadns
        forward . 127.0.0.1:5353
      }
    '';
  };
}
