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

function echo_gateway_addr() {
  if [ -n "${GATEWAY_ADDR:-}" ]; then
    echo "experimental.gatewayAddr = \"${GATEWAY_ADDR}\"",
  fi
}

function echo_china_dns_server() {
  if [ -n "${CHINA_DNS_SERVER:-}" ]; then
    echo "value.china_dns = \"${CHINA_DNS_SERVER}\"",
  fi
}

ncl_temp_file=$(mktemp --suffix .ncl)
cat <<EOF >"$ncl_temp_file"
{
   $(echo_gateway_addr)
   $(echo_china_dns_server)
}
EOF

extra_srcs+=("$ncl_temp_file")

nickel export config.ncl "${extra_srcs[@]}" >"$out"/config.json
rm "$ncl_temp_file"

for f in rule_exts/*.ncl; do
  filename="${f%.*}"
  nickel export "$f" >"$out"/"$filename".json
done


echo "build completed."
