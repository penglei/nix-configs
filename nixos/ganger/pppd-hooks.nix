{ pkgs, lib, ... }: {

  environment.etc = lib.mapAttrs (_: value: {
    text = value;
    mode = "0755";
  }) {
    "ppp/auth-up" = ''
      #!${pkgs.bash}/bin/bash

      #
      # A program or script which is executed after the remote system
      # successfully authenticates itself. It is executed with the parameters
      # <interface-name> <peer-name> <user-name> <tty-device> <speed>
      #
      PATH=/run/wrappers/bin:/usr/bin:/run/current-system/sw/bin
      export PATH

      echo auth-up `date +'%y/%m/%d %T'` $* >> /var/log/pppstats
      # last line
    '';

    "ppp/auth-down" = ''
      #!${pkgs.bash}/bin/bash

      #
      # A program or script which is executed after the remote system
      # successfully authenticates itself. It is executed with the parameters
      # <interface-name> <peer-name> <user-name> <tty-device> <speed>
      #
      export PATH=/run/wrappers/bin:/usr/bin:/run/current-system/sw/bin

      echo auth-down `date +'%y/%m/%d %T'` $* >> /var/log/pppstats
      # last line
    '';

    "ppp/ipv6-up" = ''
      #!${pkgs.bash}/bin/bash

      # Like  /etc/ppp/ip-up,  except  that it is executed when the link is available
      # for sending and receiving IPv6 packets. It is executed with the parameters
      # <interface-name> <tty-device> <speed> <local-link-local-address> <remote-link-local-address> <ipparam>
      echo ipv6-up `date +'%y/%m/%d %T'` $* >> /var/log/pppstats
      # last line
    '';

    "ppp/ipv6-down" = ''
      #!${pkgs.bash}/bin/bash

      # Similar to /etc/ppp/ip-down, but it is executed when IPv6 packets can no longer
      # be transmitted on the link. It is executed with the same  parameters as the ipv6-up script.

      echo ipv6-down `date +'%y/%m/%d %T'` $* >> /var/log/pppstats
      # last line
    '';

    "ppp/ip-up" = ''
      #!${pkgs.bash}/bin/bash

      #
      # This script is run by the pppd after the link is established.
      # It should be used to add routes, set IP address, run the mailq
      # etc.
      #
      # This script is called with the following arguments:
      #    Arg  Name               Example
      #    $1   Interface name     ppp0
      #    $2   The tty            ttyS1
      #    $3   The link speed     38400
      #    $4   Local IP number    12.34.56.78
      #    $5   Peer  IP number    12.34.56.99
      #

      #
      # The  environment is cleared before executing this script
      # so the path must be reset
      #
      export PATH=/run/wrappers/bin:/usr/bin:/run/current-system/sw/bin

      echo ip-up `date +'%y/%m/%d %T'` $* >> /var/log/pppstats
      # last line
    '';

    "ppp/ip-down" = ''
      #!${pkgs.bash}/bin/bash

      #
      # This script is run by the pppd _after_ the link is brought down.
      # It should be used to delete routes, unset IP addresses etc.
      #
      # This script is called with the following arguments:
      #    Arg  Name               Example
      #    $1   Interface name     ppp0
      #    $2   The tty            ttyS1
      #    $3   The link speed     38400
      #    $4   Local IP number    12.34.56.78
      #    $5   Peer  IP number    12.34.56.99
      #
      export PATH=/run/wrappers/bin:/usr/bin:/run/current-system/sw/bin

      echo ip-down `date +'%y/%m/%d %T'` $* >> /var/log/pppstats
      # last line
    '';
  };
}
