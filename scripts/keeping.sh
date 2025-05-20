#!/usr/bin/env bash

function red_echo() {
  echo -e "\033[31m${1}\033[0m"
}

function green_echo() {
  echo -e "\033[32m${1}\033[0m"
}

ip=${1:-100.100.0.1}
while :; do
  seconds=$(shuf -i 30-60 -n 1)
  count=$(shuf -i 1-5 -n 1)

  green_echo "Activate the connection to peer '$ip' after $seconds seconds [$(date -d "+$seconds seconds")]($count pings)."
  sleep "$seconds"

  if [ -f "/var/lib/keeping/stop" ]; then
    red_echo "Stopped keep-alive to peer '$ip'!"
    break
  fi
  #TODO update interface hook
  #e.g. `dig +short pltt.ybyte.org A | tail -n10`
  wg show wg0
  ping -W 5 -c "$count" "$ip"
done
