#!/usr/bin/env bash

#This script is used for debugging.

set -eu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$SCRIPT_DIR"/..

mkdir -p outputs

cp -r templates/* outputs

proxy_address="${PROXY_ADDRESS:-1.2.3.4}"
proxy_address_placeholder="<SOPS:$(printf "sing-box/server/address" | sha256):PLACEHOLDER>"
proxy_password="${PROXY_PASSWORD:-123456}"
proxy_password_placeholder="<SOPS:$(printf "main-password" | sha256):PLACEHOLDER>"
proxy_mock_srvname="${PROXY_MOCK_SRVNAME:-bing.com}"
proxy_mock_srvname_placeholder="<SOPS:$(printf "sing-box/shadowtls/server_name" | sha256):PLACEHOLDER>"

main_config="outputs/config.json"

sed -i "s/$proxy_address_placeholder/$proxy_address/g" $main_config
sed -i "s/$proxy_password_placeholder/$proxy_password/g" $main_config
sed -i "s/$proxy_mock_srvname_placeholder/$proxy_mock_srvname/g" $main_config

echo "render completed."
