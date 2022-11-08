{ pkgs, lib, ... }:
let
  scriptHead = ''
    #!${pkgs.bash}/bin/bash
    #
    # The  environment is cleared before executing this script
    # so the path must be reset
    #
    export PATH=/run/wrappers/bin:/usr/bin:/run/current-system/sw/bin
  '';
  logfile = "/var/log/pppd-hooks.log";
  infoLog = event: "echo ${event} `date +'%y/%m/%d %T'` $* >> ${logfile}";
  PPPoEDNSServersFile = "/var/lib/pppoe/dns-servers";
  PPPoELocalAddrIPv4 = "/var/lib/pppoe/local-ipv4";
in {

  environment.etc = lib.mapAttrs (_: value: {
    text = value;
    mode = "0755";
  }) {
    "ppp/auth-up" = ''
      ${scriptHead}
      #
      # A program or script which is executed after the remote system
      # successfully authenticates itself. It is executed with the parameters
      # <interface-name> <peer-name> <user-name> <tty-device> <speed>
      #

      ${infoLog "auth-up"}
    '';

    "ppp/auth-down" = ''
      ${scriptHead}

      #
      # A program or script which is executed after the remote system
      # successfully authenticates itself. It is executed with the parameters
      # <interface-name> <peer-name> <user-name> <tty-device> <speed>
      #

      auth-down 

    '';

    "ppp/ipv6-up" = ''
      ${scriptHead}

      # Like  /etc/ppp/ip-up,  except  that it is executed when the link is available
      # for sending and receiving IPv6 packets. It is executed with the parameters
      # <interface-name> <tty-device> <speed> <local-link-local-address> <remote-link-local-address> <ipparam>

      ${infoLog "ipv6-up"}

    '';

    "ppp/ipv6-down" = ''
      ${scriptHead}

      # Similar to /etc/ppp/ip-down, but it is executed when IPv6 packets can no longer
      # be transmitted on the link. It is executed with the same  parameters as the ipv6-up script.

      ${infoLog "ipv6-down"}

    '';

    "ppp/ip-up" = ''
      ${scriptHead}

      #
      # This script is run by the pppd after the link is established.
      # It should be used to add routes, set IP address, run the mailq etc.
      # <interface-name> <nic-device> <speed> <local-link-local-address> <remote-link-local-address> <ipparam>
      #
      ${infoLog "ip-up"}
      echo "DNS1: $DNS1" >> ${logfile}
      echo "DNS2: $DNS2" >> ${logfile}
      if [[ -n "$USEPEERDNS" ]];then
        : > ${PPPoEDNSServersFile}
        echo -n -e "$DNS1\n$DNS2" >> ${PPPoEDNSServersFile}
      fi

      if [[ "$1" == "pppoe-wan" ]]; then
        local_addr="$4"
        remote_addr="$5"

        if [[ -n "$local_addr" ]]; then
          echo -n "$local_addr" > ${PPPoELocalAddrIPv4}
        fi

        #echo replace ipv4 default route to pppoe-wan. >> ${logfile}
        #echo current ipv4 main routes: >> ${logfile}
        #ip route >> ${logfile}
        ip route replace default via $remote_addr dev pppoe-wan proto static
        #ip route >> ${logfile}
      fi

    '';

    "ppp/ip-down" = ''
      ${scriptHead}

      #
      # This script is run by the pppd _after_ the link is brought down.
      # It should be used to delete routes, unset IP addresses etc.
      #

      ${infoLog "ip-down"}

      #clean dns servers
      if [ -f ${PPPoEDNSServersFile} ];then
        rm ${PPPoEDNSServersFile}
      fi

      if [[ "$1" == "pppoe-wan" ]]; then
        echo clean ipv4 default route. >> ${logfile}
        echo current ipv4 main routes:

        #ip route >> ${logfile}
        #ip route del default via $5 dev pppoe-wan proto static
        ip route del default dev pppoe-wan proto static
        #ip route >> ${logfile}
      fi

    '';
  };
}
