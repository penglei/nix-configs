#!/usr/bin/env bash

dev=/dev/vda
label=nixos
partion_index=1
dev_part1="${dev}$partion_index"

umount /mnt || :
wipefs -a $dev_part1 || :
wipefs -a $dev || :

parted $dev -- mklabel msdos
parted $dev -- mkpart primary 1MB 100%

sleep 0.1
while [ ! -e /dev/vda1 ]; do
	sleep 0.2
done

#sleep 1
yes | mkfs.ext4 -L $label $dev_part1

while :; do
	if [ -L /dev/disk/by-label/$label ]; then
		break
	fi
	echo not exist label $label
	sleep 0.3
done

mount /dev/disk/by-label/$label /mnt
mkdir -p /mnt/boot
nixos-generate-config --root /mnt
find /mnt
