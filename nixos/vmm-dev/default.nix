{ lib, ... }:

{
  # disko is only used to build the install script. The running system keeps
  # the label-based fileSystems from ../cloud/default.nix and ../cloud-dev.nix;
  # otherwise both would define fileSystems."/" and the evaluation would fail.
  disko.enableConfig = false;

  # cloud-dev.nix pins the stateVersion of that machine's first install.
  system.stateVersion = lib.mkForce "26.11";
}
