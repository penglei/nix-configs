{ pkgs, ... }: {

  networking.firewall.extraCommands = with pkgs.lib; ''
    ${pkgs.nftables}/bin/nft -f - <<EOF
    table inet ab-forward;
    flush table inet ab-forward;
    table inet ab-forward {
      chain FORWARD {
        type filter hook forward priority filter; policy drop;
        ct state related,established accept;
        ${optionalString null ""}
      }
    }
    EOF
  '';
}

