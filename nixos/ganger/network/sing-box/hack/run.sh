#!/usr/bin/env bash

set -eu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$SCRIPT_DIR"/..

mkdir -p outputs

cd outputs

#nix run nixpkgs#sing-box -- run -c config.json

sing-box run -c config.json
