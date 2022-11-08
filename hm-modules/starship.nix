{ pkgs, ... }:

let lib = pkgs.lib;
in {
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = lib.concatStrings [
        "$username$directory$git_branch$git_state$git_status$kubernetes$time$status$line_break$character"
      ];
      username = {
        disabled = false;
        #show_always = true;
        style_user = "white bold";
        style_root = "black bold";
        format = "[ $user]($style) ";
      };
      directory = {
        truncation_length = 7;
        truncate_to_repo = false;
        truncation_symbol = "… ";
        format = "[$path]($style) ";
        style = "green";
      };
      kubernetes = {
        disabled = false;
        symbol = "󱃾 "; # ☸
        format = "([$symbol$context(\\($namespace\\))]($style) )";
        style = "blue";
        contexts = [{
          context_pattern = "void";
          context_alias = "";
          symbol = "";
        }];
      };
      git_status = {
        disabled = false;
        untracked = "";
        format =
          "([\\[$conflicted$deleted$renamed$modified$staged$behind\\]]($style) )";
        modified = "*";
      };
      status = {
        format =
          "[\\($symbol$common_meaning$signal_name$maybe_int\\)]($style) ";
        disabled = false;
        style = "red";
      };
      time = {
        disabled = false;
        #symbol = "";
        format = "[\\[$time\\]]($style)";
        time_format = "%m-%d %T";
        utc_time_offset = "+8";
        style = "yellow";
      };
      #character = {
      #  success_symbol = "[λ](grey)";
      #  error_symbol = "[λ](bold red)";
      #};
      scan_timeout = 300;
      command_timeout = 2000;
    };
  };
}
