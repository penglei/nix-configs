#!/usr/bin/env bash

set -eu -o pipefail

set -x

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CURDIR=$(cd "$SCRIPT_DIR"/.. && pwd)

sudo "$CURDIR/hack/intercept.sh" stop
sudo nft add chain inet global-proxy prerouting-proxygate '{ type filter hook prerouting priority mangle - 1; policy accept; }'

sudo "$CURDIR/hack/intercept.sh" start
sudo nft destroy chain inet global-proxy prerouting-proxygate

export PATH=$CURDIR/bin:$PATH

sing-box run -c "$CURDIR"/config.json
