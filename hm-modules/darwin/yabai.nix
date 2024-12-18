{ pkgs, config, ... }:

let
  homeProfilePath = path: "${config.home.homeDirectory}/${path}";
  yabai = "${pkgs.yabai}/bin/yabai";
in {
  # https://ss64.com/osx/launchctl.html
  launchd.agents.yabai = {
    enable = true;

    config = {
      ProgramArguments = [ "${pkgs.yabai}/bin/yabai" ];
      EnvironmentVariables = {
        "PATH" = "${homeProfilePath ".nix-profile/bin"}:${
            homeProfilePath ".local/bin"
          }:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:";
      };
      # KeepAlive = {
      #   OtherJobEnabled = builtins.listToAttrs [
      #     {
      #       name = config.launchd.agents.sketchybar.config.Label;
      #       value = true;
      #     }
      #   ];
      # };
      KeepAlive = true;
      RunAtLoad = true;
      ProcessType = "Interactive";
      #ThrottleInterval = 30;
      StandardErrorPath = "/tmp/yabai.err.log";
      StandardOutPath = "/tmp/yabai.out.log";
    };
  };

  home.file.".yabairc".text = (import ./rc/yabairc.nix) { inherit yabai; };
}

