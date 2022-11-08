#tips:

#run by root:
#export VM=router-dev; curl -L http://gg.gg/nixos-install -o - | sh

#**********docs***********
# https://nixos.org/manual/nixos/stable/index.html#sec-building-image-instructions

mkdir -p ~/.ssh
mkdir -p ~/.config/nix/
curl https://github.com/penglei.keys >>~/.ssh/authorized_keys

cat <<EOF >~/.config/nix/nix.conf
experimental-features = nix-command flakes
keep-outputs = true
keep-derivations = true
max-jobs = auto
EOF

if [ -n "$VM" ]; then
	nix run github:penglei/nix-configs#nixpkgs.nixos-installer.make-vm-disk
	nixos-install --flake github:penglei/nix-configs#$VM --no-root-password --root /mnt
fi
