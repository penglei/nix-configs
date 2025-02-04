{ lib, ... }:

let
  sopsDescrypt = keys:
    lib.foldl (acc: key: acc // { "${key}" = { sopsFile = ./server.yaml; }; })
    { } keys;
in {

  sops = { defaultSopsFile = ./basic.yaml; };

  sops.secrets = sopsDescrypt [
    "secret.main.password"
    "sing-box.server.address"
    "sing-box.shadowtls.server_name"
    "pppoe.username"
    "pppoe.password"
  ];
}
