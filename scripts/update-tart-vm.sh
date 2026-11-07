#!/usr/bin/env bash

nix run nixpkgs#nixos-rebuild -- switch --flake .#tart-vm --target-host "$USER@$(tart ip nixos)" --build-host "$USER@$(tart ip nixos)" --sudo
