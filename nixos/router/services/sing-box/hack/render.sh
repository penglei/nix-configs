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

function rawreplace_from_secrets() {
	local key_path="$1"
	local placeholder="\"<RAW-PLACEHOLDER:${key_path}>"\"
	local yq_key_path
	yq_key_path=$(printf '%s' "$key_path" | tr "/" ".")
	local value
	value=$(sops -d "${project_root}/secrets/secrets.yaml" | yq ".${yq_key_path}")
	sed -i "s,$placeholder,$value,g" $main_config
}

replace_from_secrets "main-password"

replace_from_secrets "sing-box/sv-alpha/v2ray-plugin/opts"
replace_from_secrets "sing-box/hk-alpha/address"
replace_from_secrets "sing-box/hk-alpha/shadowtls/server_name"

replace_from_secrets "sing-box/sv-alpha/address"
replace_from_secrets "sing-box/sv-alpha/shadowtls/server_name"

replace_from_secrets "proxies/subscribe-a/common/server"
rawreplace_from_secrets "proxies/subscribe-a/server1/port"
replace_from_secrets "proxies/subscribe-a/common/method"
replace_from_secrets "proxies/subscribe-a/common/password"
replace_from_secrets "proxies/subscribe-a/common/plugin"
replace_from_secrets "proxies/subscribe-a/common/plugin_opts"

replace_from_secrets "proxies/subscribe-b/server1/addr"
rawreplace_from_secrets "proxies/subscribe-b/common/port"
replace_from_secrets "proxies/subscribe-b/common/method"
replace_from_secrets "proxies/subscribe-b/common/password"

echo "render completed."
