default:
	@echo "please provide the target."

pin-registry:
	@nix registry pin nixpkgs "github:NixOS/nixpkgs/$$(cat flake.lock|jq -r '.nodes[.nodes.root.inputs.nixpkgs].locked.rev')"
	@nix registry pin home-manager github:nix-community/home-manager/$$(cat flake.lock|jq -r '.nodes["home-manager"].locked.rev')

update-sops:
	sops updatekeys secrets/basic.yaml 
	sops updatekeys secrets/server.yaml

edit-backup:
	@./scripts/edit-backup.sh

restore:
	@./scripts/restore.sh

apply-dotfiles:
	chezmoi apply

switch:
	@if [[ "$$(uname)" == "Darwin" ]]; then \
		home-manager switch --flake .; \
	else \
		sudo nixos-rebuild switch --flake .; \
	fi
