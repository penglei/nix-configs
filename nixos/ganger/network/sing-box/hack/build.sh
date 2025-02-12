#!/usr/bin/env bash

set -eu -o pipefail
shopt -s nullglob

SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_PATH}/.." || return

out="${1:-templates}"
mkdir -p "$out"/rule_exts

#extension="${filename##*.}"
#filename="${filename%.*}"

nickel export config.ncl >"$out"/config.json
for f in rule_exts/*.ncl; do
	filename="${f%.*}"
	nickel export "$f" >"$out"/"$filename".json
done

echo "build completed."
