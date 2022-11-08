#!/usr/bin/env bash

set -euo pipefail

TABLE=global

if nft list tables | grep -q $TABLE; then
  # nft flush table inet $TABLE
  nft flush set inet $TABLE chnroute
  nft flush set inet $TABLE chnroute6
fi

# while IFS= read -r line; do
#   nftset_name=chnroute
#   if [[ "$line" == *:* ]]; then
#     nftset_name=chnroute6
#   fi
#   nft add element inet $TABLE $nftset_name "{$line}"
# done <cn.txt

chnroute() {
  while IFS= read -r line; do
    echo "$line",
  done <chnroute.txt
}

chnroute6() {
  while IFS= read -r line; do
    echo "$line",
  done <chnroute6.txt
}

cat <<EOF | nft -f -
table inet global-proxy {
  set chnroute {
    type ipv4_addr
    flags interval
    elements = { $(chnroute) }
  }
  set chnroute6 {
    type ipv6_addr
    flags interval
    elements = { $(chnroute6) }
  }
}

EOF
