{ profiles, microvm, attic, ... }:

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

      #a nix binary cache service
      # attic.nixosModules.atticd
    ];
    hm-modules = profiles.hm.base.modules;
  };

  tart-vm = {
    username = "penglei";
    system = "aarch64-linux";
    modules = [ ./secrets ./nixos/tart-vm ];
  };

  router = {
    username = "penglei";
    modules = [ ./nixos/router/instance ];
    hm-modules = profiles.hm.router.modules;
  };

  hk-alpha = {
    username = "penglei";
    modules = [
      ./secrets

      ./nixos/cloud/hk-alpha.nix
    ];
    hm-modules = profiles.hm.linux.modules;
  };

  sv-alpha = {
    username = "penglei";
    modules = [
      ./secrets
      ./nixos/cloud
      ./nixos/cloud/sv-alpha.nix

      ((import ./nixos/modules/sing-box-server.nix) {
        proxy_name = "sv-alpha";
      })
    ];
    hm-modules = profiles.hm.slim.modules;
  };

  cloud-dev = {
    username = "penglei";
    hm-modules = profiles.hm.linux.modules ++ [
      ({ pkgs, ... }: {
        home.packages = with pkgs; [
          kubectl
          k9s
          #kustomize
          #krew
          kubectl-kubectx
          kubectl-kubecm
          kubectl-nodeshell
        ];
      })
    ];

    modules = [
      ./nixos/cloud

      ./nixos/cloud-dev.nix
    ];
  };
}
