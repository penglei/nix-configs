{ system, profiles, nixpkgs, pkgOverlays, ... }:

let
  cloudconfig = {
    inherit system nixpkgs;
    overlays = pkgOverlays;
    username = "penglei";
    modules = [ ./nixos/cloud ];
    hm-modules = profiles.hm.slim.modules;
  };
in {
  slim = profiles.nixos-creator {
    inherit system nixpkgs;
    overlays = pkgOverlays;
    hostname = "nixos";
    username = "penglei";
    modules = [ ./nixos/basic ];
    hm-modules = profiles.hm.slim.modules;
  };
  basic = profiles.nixos-creator {
    inherit system nixpkgs;
    overlays = pkgOverlays;
    hostname = "nixos";
    username = "penglei";
    modules = [ ./nixos/basic ];
  };

  ganger = profiles.nixos-creator {
    inherit system nixpkgs;
    overlays = pkgOverlays;
    hostname = "ganger";
    username = "penglei";
    modules = [ ./nixos/ganger ];
    hm-modules = profiles.hm.base.modules;
  };

  utm-vm = profiles.nixos-creator {
    inherit system nixpkgs;
    overlays = pkgOverlays;
    hostname = "utm-vm";
    username = "penglei";
    modules = [ ./nixos/utm-vm ];
  };

  tart-vm = profiles.nixos-creator {
    inherit system nixpkgs;
    overlays = pkgOverlays;
    hostname = "tart-vm";
    username = "penglei";
    modules = [ ./nixos/tart-vm ];
  };

  router-dev = profiles.nixos-creator {
    inherit system nixpkgs;
    overlays = pkgOverlays;
    hostname = "router-dev";
    username = "penglei";
    modules = [ ./nixos/router-dev ];
    hm-modules = profiles.hm.slim.modules;
  };
  installer = profiles.nixos-creator {
    inherit system nixpkgs;
    overlays = pkgOverlays;
    hostname = "installer";
    username = "penglei";
    modules = [ ./nixos/installer ];
    hm-modules = profiles.hm.slim.modules;
  };

  hk-alpha = profiles.nixos-creator {
    inherit system nixpkgs;
    overlays = pkgOverlays;
    hostname = "hk-alpha";
    username = "penglei";
    modules = [
      ./nixos/cloud

      ./nixos/modules/ssserver.nix
    ];
    hm-modules = profiles.hm.slim.modules;
  };

  sg-alpha = profiles.nixos-creator {
    inherit system nixpkgs;
    overlays = pkgOverlays;
    hostname = "sg-alpha";
    username = "penglei";
    modules = [
      ./nixos/cloud

      ./nixos/modules/dnscrypt-proxy-server.nix
    ];
    hm-modules = profiles.hm.slim.modules;
  };

  sv-alpha = profiles.nixos-creator (cloudconfig // { hostname = "sv-alpha"; });
}
