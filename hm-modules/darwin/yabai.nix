{ pkgs, config, ... }:

let yabai = "${pkgs.yabai}/bin/yabai";
in {
  # https://ss64.com/osx/launchctl.html
  launchd.agents.yabai = {
    enable = true;

    config = {
      ProgramArguments = [ "${pkgs.yabai}/bin/yabai" ];
      EnvironmentVariables = {
        "PATH" = config.launch_agent_common.path_env;
        "SHELL" = "/bin/sh";
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

  home.file."${config.xdg.configHome}/yabai/yabairc".text =
    (import ./rc/yabairc.nix) { inherit yabai; };
  home.file."${config.xdg.configHome}/yabai/event.sh".source =
    ../../files/dotfiles/_config/yabai/events.sh;
  home.file."${config.xdg.configHome}/yabai/focus_space_window.sh".source =
    ../../files/dotfiles/_config/yabai/focus_space_window.sh;
}

