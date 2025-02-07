default:
	@echo "please provide the target."

SYSTEM=$(shell nix eval --expr 'builtins.currentSystem' --impure --raw)

pin-registry:
	@if [[ "$(SYSTEM)" == *darwin ]]; then \
		nix registry pin nixpkgs "github:NixOS/nixpkgs/$$(cat flake.lock|jq -r '.nodes[.nodes.root.inputs.nixpkgs].locked.rev')"; \
		nix registry pin home-manager github:nix-community/home-manager/$$(cat flake.lock|jq -r '.nodes["home-manager"].locked.rev'); \
	fi

update-sops:
	sops updatekeys secrets/basic.yaml 
	sops updatekeys secrets/server.yaml

edit-backup:
	@./scripts/edit-backup.sh

restore:
	@./scripts/restore.sh

apply:
	if [[ "$(SYSTEM)" == *darwin ]]; then \
		chezmoi apply; \
		home-manager switch --flake .#penglei.$(SYSTEM); \
	else \
		if [[ "$$(uname -a)" == *NixOS* ]]; then \
			sudo nixos-rebuild switch --flake .; \
		else \
			home-manager switch --flake .#penglei.$(SYSTEM); \
		fi \
	fi

MACHINE ?= ganger
rsync:
	rsync -avh . $(MACHINE):/data/nix-configs \
	--exclude .direnv --include='**.gitignore' --filter=':- .gitignore' --delete-after
