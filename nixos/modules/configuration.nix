{ pkgs, lib, username, hostname, ... }:

let default_ssh_auth_key = (import ../../config.nix).ssh.authorized_key;
in {

  programs.neovim = {
    viAlias = true;
    vimAlias = true;
  };

  # programs.nix-ld.enable = true; # TODO enable!

  # Set your time zone.
  time.timeZone = lib.mkDefault "Asia/Shanghai";

  networking.hostName = hostname;

  #No need on a server
  fonts.fontconfig.enable = lib.mkDefault false;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = { keyMap = "us"; };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ default_ssh_auth_key ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

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

  boot.kernelParams = [ "console=ttyS0,115200" "console=tty1" ];
}

