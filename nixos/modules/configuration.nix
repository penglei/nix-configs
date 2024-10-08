{ config, pkgs, lib, username, ... }:

let default_ssh_auth_key = (import ../../config.nix).ssh.authorized_key;
in {

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  #No need on a server
  # sound.enable = false;
  fonts.fontconfig.enable = lib.mkDefault false;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = { keyMap = "us"; };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [ default_ssh_auth_key ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true; # by: users.users.*.shell = zsh

  users.users.root = {
    openssh.authorizedKeys.keys = [ default_ssh_auth_key ];
  };

  security.sudo = {
    extraRules = [{
      users = [ username ];
      commands = [{
        command = "ALL";
        options = [
          "NOPASSWD"
          "SETENV"
        ]; # "SETENV" # Adding the following could be a good idea
      }];
    }];
  };
}

