#!/usr/bin/env bash

#This script is used for debugging.

set -eu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$SCRIPT_DIR"/..

mkdir -p outputs

cp -r templates/* outputs

main_config="outputs/config.json"
project_root=$(git rev-parse --show-toplevel)

function replace_from_secrets() {
  local key_path="$1"
  local placeholder="<PLACEHOLDER:${key_path}>"
  local yq_key_path
  yq_key_path=$(printf '%s' "$key_path" | tr "/" ".")
  local value
  value=$(sops -d "${project_root}/secrets/secrets.yaml" | yq ".${yq_key_path}")

  sed -i "s,$placeholder,$value,g" $main_config
}

replace_from_secrets "main-password"
replace_from_secrets "sing-box/server/address"
replace_from_secrets "sing-box/shadowtls/server_name"

echo "render completed."
