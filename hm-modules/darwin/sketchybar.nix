{ pkgs, config, ... }:

let homeProfilePath = path: "${config.home.homeDirectory}/${path}";
in {
  # https://ss64.com/osx/launchctl.html
  launchd.agents.sketchybar = {
    enable = true;

    config = {
      ProgramArguments = [ "${pkgs.sketchybar}/bin/sketchybar" ];
      EnvironmentVariables = {
        "PATH" = "${homeProfilePath ".nix-profile/bin"}:${
            homeProfilePath ".local/bin"
          }:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:";
        "SHELL" = "/bin/sh";
      };
      KeepAlive = true;
      RunAtLoad = true;
      StandardErrorPath = "/tmp/sketchybar.err.log";
      StandardOutPath = "/tmp/sketchybar.out.log";
    };
  };

  home.file = let
    files = map (name: {
      path = ../../files/dotfiles/.config/sketchybar/${name};
      name = ".config/sketchybar/${name}";
    }) [
      "sketchybarrc"
      "plugins/battery.sh"
      "plugins/clock.sh"
      "plugins/front_app.sh"
      "plugins/space.sh"
      "plugins/window_title.sh"
      "plugins/yabai_space_label.sh"
      "plugins/yabai_space_state.sh"
      "plugins/yabai_window_state.sh"
      "plugins/yabai_windows_opacity.sh"
    ];

  in builtins.listToAttrs (map (file: {
    name = file.name;
    value = { source = file.path; };
  }) files);
}

