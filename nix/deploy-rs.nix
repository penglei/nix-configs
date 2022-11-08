{ self, deploy-rs, ... }:
let
  machine =
    (name: deploy-rs.lib.activate.nixos self.nixosConfigurations."${name}");
in {
  # sshUser = "penglei";
  magicRollback = false;
  nodes = {
    "ganger" = {
      hostname = "192.168.101.100";
      profiles.system = {
        user = "root";
        path = machine "ganger";
      };
    };
    "router" = {
      hostname = "192.168.101.1";
      profiles.system = {
        user = "root";
        path = machine "router";
      };
    };
  };
}
