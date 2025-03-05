#!/usr/bin/env bash

set -eu -o pipefail

set -x

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CURDIR=$(cd "$SCRIPT_DIR"/.. && pwd)

sudo "$CURDIR/hack/intercept.sh" stop
sudo "$CURDIR/hack/intercept.sh" start

export PATH=$CURDIR/bin:$PATH

sing-box run -c "$CURDIR"/config.json
