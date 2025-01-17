default:
	echo "please provide the target."

pin-registry:
	@nix registry pin nixpkgs "github:NixOS/nixpkgs/$$(cat flake.lock|jq -r '.nodes[.nodes.root.inputs.nixpkgs].locked.rev')"
	@nix registry pin home-manager github:nix-community/home-manager/$$(cat flake.lock|jq -r '.nodes["home-manager"].locked.rev')

sops-update:
	sops updatekeys secrets/basic.yaml 
	sops updatekeys secrets/server.yaml

secret-update:
	./scripts/edit-backup.sh

switch:
	sudo nixos-rebuild switch --flake .
