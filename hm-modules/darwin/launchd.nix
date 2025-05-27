{ lib, config, ... }:
with lib;
let
  homePath = path: "${config.home.homeDirectory}/${path}";
  cfg = config.launch_agent_common;
in {
  options = {
    launch_agent_common.paths = mkOption {
      type = with types; listOf str;
      default = [ ];
    };
    launch_agent_common.path_env = mkOption {
      default = null;
      type = types.nullOr types.str;

    };
  };
  config = {
    launch_agent_common.paths = [
      "${homePath ".nix-profile/bin"}"
      "${homePath ".local/bin"}"
      "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    ];
    launch_agent_common.path_env = strings.concatStringsSep ":" cfg.paths;
  };
}
