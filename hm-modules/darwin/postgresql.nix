{ pkgs, ... }:

{
  launchd.agents.postgresql = {
    enable = true;

    config = {
      ProgramArguments = [ "${pkgs.postgresql}/bin/postgres" ];
      EnvironmentVariables = { "SHELL" = "/bin/sh"; };
      KeepAlive = true;
      RunAtLoad = false;
      StandardErrorPath = "/tmp/postgresql.err.log";
      StandardOutPath = "/tmp/postgresql.out.log";
    };
  };
}

