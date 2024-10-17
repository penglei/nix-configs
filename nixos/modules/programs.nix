{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    ripgrep
    pstree
    file
    curl
  ]; # merge syntatics
}
