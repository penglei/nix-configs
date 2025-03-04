# split from flake.nix to prevent it cause nix-direnv refresh while changed.
{ pkgs, ... }:
{
  ##for debugging(N.B. track new files before building), e.g.:
  ##❯ nix build .#pkgs.chinadns-ng-prebuilt
  # packages.pkgs = pkgs;
}
