#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../secrets"

#prepare(backup destination)
data_base_dir="$HOME/.passage"
mkdir -p "$data_base_dir"
bak_dir=$(mktemp -d "$data_base_dir/store-$(date +%s)-XXXX")

if [[ -d "$data_base_dir/store" ]]; then
	cp -R "$data_base_dir"/store/* "$bak_dir"
fi

datafile="recovery.enc"

workdir=local-extraction-for-restore-passage
mkdir -p "$workdir"

echo "Enter pin to show superkey:"
if [ -f "$data_base_dir/store/superkey.age" ]; then
	passage superkey
fi

#restore from encrypted file
if [[ -f "$datafile" ]]; then
	pushd "$workdir" >/dev/null
	age -d ../recovery.enc >x.tgz #need superkey password here
	tar -zxf x.tgz                #extract recovery directory
	rm x.tgz
	mkdir -p "$data_base_dir/store"
	cp -R recovery/passage/* "$data_base_dir/store"
	popd >/dev/null
else
	mkdir -p "$workdir/recovery"
fi

rm -rf $workdir
