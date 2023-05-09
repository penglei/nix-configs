# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix # delete it and run command nixos-generate-config to generate again
    ];

  nix = {
    package = pkgs.nixUnstable; # or versioned attributes like nix_2_4
    settings = {
      use-cgroups = true;
      auto-allocate-uids = true;
      experimental-features = [ "nix-command" "flakes" "auto-allocate-uids" "cgroups" ];
    };

    #extraOptions = ''
    #  Experimental-features = nix-command flakes
    #'';
  };
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "us";
  };

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.penglei = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker"]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [ (import ../../config.nix).ssh.authorized_key ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  security.sudo.extraRules= [
    {  users = [ "penglei" ];
      commands = [
         { command = "ALL" ;
           options= [ "NOPASSWD" "SETENV" ]; # "SETENV" # Adding the following could be a good idea
        }
      ];
    }
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
    ripgrep
    bcc
    pstree
    busybox

    #vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.

    #firefox-wayland
    #alacritty # gpu accelerated terminal
    #sway
    #wayland
  ];
  # enable sway window manager
  #programs.sway.enable = true;
  #programs.waybar.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.PermitRootLogin = "yes";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

  virtualisation.docker.enable = true;
}
