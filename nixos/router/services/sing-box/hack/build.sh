#!/usr/bin/env bash

set -eu -o pipefail
shopt -s nullglob

SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_PATH}/.." || return

out="${1:-templates}"
mkdir -p "$out"/rule_exts

#extension="${filename##*.}"
#filename="${filename%.*}"

extra_srcs=()

function echo_gatewayAddr() {
  if [ -n "${GATEWAY_ADDR:-}" ]; then
    echo "experimental.gatewayAddr = \"${GATEWAY_ADDR}\","
  fi
}

temp_file=$(mktemp --suffix .ncl)
cat <<EOF >"$temp_file"
{
  $(echo_gatewayAddr)
}
EOF

extra_srcs+=("$temp_file")

nickel export config.ncl "${extra_srcs[@]}" >"$out"/config.json
for f in rule_exts/*.ncl; do
  filename="${f%.*}"
  nickel export "$f" >"$out"/"$filename".json
done

echo "build completed."
