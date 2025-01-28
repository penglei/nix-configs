{ lib, config, ... }:
with lib;
let
  homeProfilePath = path: "${config.home.homeDirectory}/${path}";
  cfg = config.launch_agent_common;
in {
  options = {
    launch_agent_common.paths = mkOption {
      type = with types; listOf str;
      default = [
        "${homeProfilePath ".nix-profile/bin"}"
        "${homeProfilePath ".local/bin"}"
        "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
      ];
    };
    launch_agent_common.path_env = mkOption {
      default = null;
      type = types.nullOr types.str;

    };
  };
  config = {
    launch_agent_common.path_env = strings.concatStringsSep ":" cfg.paths;
  };
}
