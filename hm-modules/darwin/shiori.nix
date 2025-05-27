{ pkgs, config, lib, ... }:

let
  cfg = config.launchd.agents.shiori;
  envs = {
    SHIORI_DIR = "${config.home.homeDirectory}/Data/shiori/data";
    SHIORI_HTTP_SECRET_KEY = "local-web-session~~";
    SHIORI_HTTP_PORT = "7030";
  };
in {
  imports = [{
    config = lib.mkIf cfg.enable {
      home.sessionVariables = envs;
      launch_agent_common.paths = [ "${pkgs.shiori}/bin" ];
    };
  }];

  #show log:
  #> log show --predicate 'process == "launchd" --last 5m
  launchd.agents.shiori = {
    enable = true;

    config = {

      ProgramArguments = [ "/usr/bin/env" "shiori" "server" ];
      EnvironmentVariables = envs // {
        "PATH" = config.launch_agent_common.path_env;
      };
      KeepAlive = true;
      RunAtLoad = true;
      ProcessType = "Background";
      StandardErrorPath = "/tmp/shiori.err.log";
      StandardOutPath = "/tmp/shiori.out.log";
    };
  };
}
