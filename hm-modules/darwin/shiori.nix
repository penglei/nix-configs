{ pkgs, config, lib, ... }:

let
  envs = {
    SHIORI_DIR = "${config.home.homeDirectory}/Data/shiori/data";
    SHIORI_HTTP_SECRET_KEY = "local-web-session~~";
    SHIORI_HTTP_PORT = "7030";
  };
in {
  home.sessionVariables = envs;
  launchd.agents.shiori = {
    enable = true;

    config = {
      ProgramArguments = [ "${pkgs.shiori}/bin/shiori" "server" ];
      EnvironmentVariables = envs // {
        "PATH" = lib.strings.concatStringsSep ":" [
          "${config.home.homeDirectory}/.nix-profile/bin"
          "/usr/local/bin"
          "/usr/bin"
          "/bin"
          "/usr/sbin"
          "/sbin"
        ];
      };
      KeepAlive = true;
      RunAtLoad = true;
      ProcessType = "Background";
      StandardErrorPath = "/tmp/shiori.err.log";
      StandardOutPath = "/tmp/shiori.out.log";
    };
  };
}
