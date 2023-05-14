{ config, pkgs, lib, ... }:

let 
  default_ssh_auth_key = (import ../../config.nix).ssh.authorized_key;
in
{

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "us";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.penglei = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker"]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [ default_ssh_auth_key ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true; #by: users.users.*.shell = zsh

  users.users.root = {
    openssh.authorizedKeys.keys = [ default_ssh_auth_key ];
  };

  security.sudo.extraRules= [
    {  users = [ "penglei" ];
      commands = [
         { command = "ALL" ;
           options= [ "NOPASSWD" "SETENV" ]; # "SETENV" # Adding the following could be a good idea
        }
      ];
    }
  ];
}
