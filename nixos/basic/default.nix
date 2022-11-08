{ ... }:

{
  imports = [
    ../nix.nix
    ../modules/configuration.nix
    ../modules/programs.nix
    ../modules/openssh.nix
    ../modules/pam.nix
  ];

  #CAUTION: These modules ared loaded in boot stage-1, which are required
  #  to recognize block device that contains rootfs for stage-2.
  #  Run `nixos-generate-config` to determine the required modules.
  boot.initrd.availableKernelModules = [ ];

  #see: <nixpkgs>/nixos/modules/tasks/filesystems.nix
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}

