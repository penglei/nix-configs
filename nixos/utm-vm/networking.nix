{ config, pkgs, lib, hostname, ... }:

#https://nixos.wiki/wiki/Networking
{
  networking = {
    hostName = hostname;

    useDHCP = false;
    dhcpcd.enable = false;
    defaultGateway = "192.168.65.1";
    nameservers = [ "192.168.65.1" ];
    interfaces.enp0s1 = {
      ipv4.addresses = [{
        address = "192.168.65.5";
        prefixLength = 24;
      }];
    };
  };
}
