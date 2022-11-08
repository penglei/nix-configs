#!/usr/bin/env bash

set -euo pipefail

## sources
## https://github.com/Loyalsoldier/v2ray-rules-dat
## https://github.com/Loyalsoldier/geoip

curl -4fsSkL -O https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/china-list.txt
# or(contains regex): https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/direct-list.txt

curl -4fsSkL -O https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/gfw.txt

# china ip range
curl -4fsSkL -O https://raw.githubusercontent.com/pexcn/daily/gh-pages/chnroute/chnroute.txt
curl -4fsSkL -O https://raw.githubusercontent.com/pexcn/daily/gh-pages/chnroute/chnroute6.txt

# # https://github.com/Loyalsoldier/geoip/blob/release/text/cn.txt
# curl -4fsSkL https://raw.githubusercontent.com/Loyalsoldier/geoip/refs/heads/release/text/cn.txt
# #geoip里面的ipv6太精细，我们不需要如此高精度(地理位置)的判断
