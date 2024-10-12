{ pkgs, ... }:

{
  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    neovim
    ripgrep
    bcc
    pstree
    busybox
    #vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  ];
}
