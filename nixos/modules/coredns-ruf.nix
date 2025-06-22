# { lib, config, ... }: {
#   services.coredns = {
#     enable = lib.mkDefault false;
#     config = ''
#       . {
#         bind ${config.netaddr.ipv4.dns}
#         cache
#         #forward to local chinadns
#         forward . 127.0.0.1:5353
#       }
#     '';
#   };
# }

{ lib, pkgs, ... }:
let
  configFile = pkgs.writeText "Corefile" ''
    .:15353 {
      forward . 127.0.0.1:15301 127.0.0.1:15302 127.0.0.1:15303
      cache
    }
    .:15301 {
        forward . tls://8.8.8.8 tls://8.8.4.4 {
            tls_servername dns.google
        }
    }
    .:15302 {
        forward . tls://1.1.1.1 tls://1.0.0.1 {
            tls_servername cloudflare-dns.com
        }
    }
    .:15303 {
      forward github.com 183.60.82.98 183.60.83.19
      forward googlevideo.com 183.60.82.98 183.60.83.19
    }

    ## need compile with unbound plugin
    # .:5353 {
    #     unbound
    #     cache
    #     log
    # }
  '';
in
{
  systemd.services.coredns-ruf = {
    description = "Coredns dns server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    preStart = ''
      dirty_lock_file="$STATE_DIRECTORY/dirty.lock"
      if [ -f "$dirty_lock_file" ]; then
        echo "$dirty_lock_file exist, coredns-ruf configuration is not overrided."
      else
        cat ${configFile} > $STATE_DIRECTORY/coredns.cfg
      fi
    '';
    serviceConfig = {
      StateDirectory = "coredns-ruf";
      StateDirectoryMode = "0700";
      PermissionsStartOnly = true;
      LimitNPROC = 512;
      LimitNOFILE = 1048576;
      CapabilityBoundingSet = "cap_net_bind_service";
      AmbientCapabilities = "cap_net_bind_service";
      NoNewPrivileges = true;
      DynamicUser = true;
      ExecStart = "${lib.getBin pkgs.coredns}/bin/coredns -conf=\${STATE_DIRECTORY}/coredns.cfg";
      ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR1 $MAINPID";
      Restart = "on-failure";
    };
  };
}
