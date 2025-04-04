{ profiles, microvm, ... }:

{
  # slim = {
  #   hostname = "nixos";
  #   username = "penglei";
  #   modules = [ ./nixos/basic ];
  #   hm-modules = profiles.hm.slim.modules;
  # };
  # basic = {
  #   hostname = "nixos";
  #   username = "penglei";
  #   modules = [ ./nixos/basic ];
  # };

  installer = {
    username = "penglei";
    modules = [ ./nixos/installer ];
    hm-modules = profiles.hm.slim.modules;
  };

  ganger = {
    username = "penglei";
    modules = [
      ./nixos/ganger

      # Include the microvm host module
      microvm.nixosModules.host
    ];
    hm-modules = profiles.hm.base.modules;
  };

  # utm-vm = {
  #   username = "penglei";
  #   system = "aarch64-linux";
  #   modules = [ ./nixos/utm-vm ];
  # };

  tart-vm = {
    username = "penglei";
    system = "aarch64-linux";
    modules = [ ./nixos/tart-vm ];
  };

  router = {
    username = "penglei";
    modules = [ ./nixos/router ];
    hm-modules = profiles.hm.slim.modules;
  };

  hk-alpha = {
    username = "penglei";
    modules = [
      ./nixos/cloud

      ((import ./nixos/modules/sing-box-server.nix) {
        proxy_name = "hk-alpha";
      })
    ];
    hm-modules = profiles.hm.slim.modules;
  };

  sg-alpha = {
    username = "penglei";
    modules = [
      ./nixos/cloud

      ./nixos/modules/dnscrypt-proxy-server.nix
    ];
    hm-modules = profiles.hm.slim.modules;
  };

  sv-alpha = {
    username = "penglei";
    modules = [ ./nixos/cloud ./nixos/cloud/sv-alpha0.nix ];
    hm-modules = profiles.hm.slim.modules;
  };
}
