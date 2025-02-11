{ config, ... }:

let keyfileInHome = ".config/sops/age/keys.txt";
in {
  sops = { age.keyFile = "${config.home.homeDirectory}/${keyfileInHome}"; };
}
