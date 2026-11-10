{ profiles, microvm, attic, disko, ... }:

let
  devHmModules = profiles.hm.linux.modules ++ [
    ./hm-modules/lldb.nix
    ({ pkgs, ... }: {
      home.packages = with pkgs; [
        kubectl
        #k9s
        #kustomize
        #krew
        kubectl-kubectx
        kubectl-kubecm
        kubectl-nodeshell

        bc
        bison
        clang_22
        envsubst
        flamegraph
        flex
        graphviz
        kubernetes-helm
        lld
        lldb_22
        llvm_22
        nodejs
        perf
        postgresql
        procs
        tree-sitter
        yazi
      ];
    })
  ];
in
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
    modules = [
      ./secrets
      disko.nixosModules.disko
      ./nixos/tart-vm
    ];
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
    hm-modules = devHmModules;

    modules = [
      ./nixos/cloud

      ./nixos/cloud-dev.nix
    ];
  };

  vmm-dev = {
    username = "penglei";
    hm-modules = devHmModules;

    modules = [
      ./nixos/cloud

      ./nixos/cloud-dev.nix

      # Same dev machine, but installed from a kexec environment with disko:
      # the installer formats both disks and labels them nixos/data.
      ./nixos/vmm-dev
      disko.nixosModules.disko
      ./nixos/vmm-dev/disko-config.nix
    ];
  };
}
