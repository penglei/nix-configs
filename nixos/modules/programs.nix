{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    ripgrep
    pstree
    file
    curl
    gnumake
    nixVersions.latest
  ]; # merge syntatics
}
