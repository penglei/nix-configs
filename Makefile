default:
	@echo "please provide the target."

SHELL=bash

SYSTEM=$(shell nix eval --expr 'builtins.currentSystem' --impure --raw)

pin-registry:
	@if [[ "$(SYSTEM)" == *darwin ]]; then \
		nix registry pin nixpkgs "github:NixOS/nixpkgs/$$(cat flake.lock|jq -r '.nodes[.nodes.root.inputs.nixpkgs].locked.rev')"; \
		nix registry pin home-manager github:nix-community/home-manager/$$(cat flake.lock|jq -r '.nodes["home-manager"].locked.rev'); \
	fi

update-sops:
	sops updatekeys secrets/basic.yaml 
	sops updatekeys secrets/secrets.yaml

edit-backup:
	@./scripts/edit-backup.sh

restore:
	@./scripts/restore.sh

apply:
	@if [[ "$$NIX_PROFILES" == "" ]]; then \
		echo "NIX_PROFILES is empty! (/etc/zshrc should be imported from /etc/zsh/zshrc manually in ubuntu)"; \
		exit 1; \
	fi; \
	if [[ "$(SYSTEM)" == *darwin ]]; then \
		chezmoi apply; \
		home-manager switch --flake .#penglei.$(SYSTEM); \
	else \
		if [[ "$$(uname -a)" == *NixOS* ]]; then \
			sudo nixos-rebuild switch --flake .; \
		else \
			home-manager switch --flake .#$$USER.$(SYSTEM); \
		fi \
	fi

build:
	if [[ "$(SYSTEM)" == *darwin ]]; then \
		home-manager build --flake .#penglei.$(SYSTEM); \
	else \
		if [[ "$$(uname -a)" == *NixOS* ]]; then \
			sudo nixos-rebuild build --flake .; \
		else \
			home-manager build --flake .#$$USER.$(SYSTEM); \
		fi \
	fi

ROUTER?=192.168.101.1
#nixos-rebuild-ng switch --flake .#router --target-host root@$$ROUTER
#nix run nixpkgs#deploy-rs -- .#router --hostname=$$ROUTER
update-router:
	nixos-rebuild-ng build --flake .#router
	sleep 3
	export pathToConfig=$$(realpath ./result); \
	echo pathToConfig: $$pathToConfig; \
	nix copy --to ssh://$$ROUTER $$pathToConfig; \
	ssh root@$$ROUTER \
		nix-env -p /nix/var/nix/profiles/system --set $$pathToConfig; \
	ssh root@$$ROUTER \
		systemd-run -E LOCALE_ARCHIVE -E NIXOS_INSTALL_BOOTLOADER= \
		--collect --no-ask-password --pipe --quiet --service-type=exec \
		--unit=nixos-rebuild-switch-to-configuration --wait \
		/nix/var/nix/profiles/system/bin/switch-to-configuration switch;


SERVER ?= ganger
rsync:
	rsync -avh . $(SERVER):/data/nix-configs \
	--exclude .direnv \
	--exclude .git/config \
	--exclude .git/hooks \
	--exclude stuff/pre-builtis/darwin/
	--include='**.gitignore' \
	--filter=':- .gitignore' \
	--delete-after

