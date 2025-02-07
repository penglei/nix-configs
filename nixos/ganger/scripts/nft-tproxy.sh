#!/usr/bin/env bash

set -euo pipefail
#OUTPUT_INTERFACE=$(ip route show default | awk '/default/ {print $5}')
OUTPUT_INTERFACE="pppoe-wan"

## sing-box tproxy inbound
TPROXY_PORT=21012

#sing-box outbound connection
## SO_MARK, rules.default_mark
#see https://sing-box.sagernet.org/configuration/route/#default_mark
OUT_MARK=666

PROXY_FWMARK=119

#https://book.huihoo.com/iptables-tutorial/x9125.htm

#  [family]          [type][   gateway  ] [table]
ip -4 route replace local default dev lo table 100
if ! (ip -4 rule show | grep -q 100); then
  ip -4 rule add fwmark 119 lookup 100
fi

ip -6 route replace local default dev lo table 100
if ! (ip -6 rule show | grep -q 100); then
  ip -6 rule add fwmark $PROXY_FWMARK lookup 100
fi

#`meta` connection metadata, `l4proto` can match ipv6 packet
#`th` means "Transport Header".
#`fib` means forwarding information base

table=sing-box-tproxy

if nft list tables | grep -q $table; then
  nft flush table inet $table
fi

nft -f - <<EOF
table inet $table {

  #debug的时候可以临时不代理lan中的某台机器
  set src_bypass {
    typeof ip saddr
    flags interval
    auto-merge
    #elements = { }
  }

  set dst_bypass {
    typeof ip daddr
    flags interval
    auto-merge
    elements = {
      0.0.0.0/8, 10.0.0.0/8, 100.64.0.0/10, 127.0.0.0/8, 169.254.0.0/16,
      172.16.0.0/12, 192.0.0.0/24, 192.0.2.0/24, 192.31.196.0/24,
      192.52.193.0/24, 192.88.99.0/24, 192.168.0.0/16, 192.175.48.0/24,
      198.18.0.0/15, 198.51.100.0/24, 203.0.113.0/24, 224.0.0.0/4, 240.0.0.0/4,
      255.255.255.255,
    }
  }

  set dst_bypass6 {
    typeof ip6 daddr
    flags interval
    auto-merge
    elements = {
      ::1/128, ::/128, ::ffff:0:0/96, 64:ff9b:1::/48, 100::/64,
      2001:2::/48, 2001:db8::/32, fe80::/10, 2001::/23, fc00::/7,
    }
  }

  # 我们透明代理是尽量forward，一般不需要单独配置forward的场景。
  # 除非哪天我们优化性能，将一些dst bypass的判断offload到nftables中出现误判时，
  # 才需要手动修正。
  # set dst_forward {}

  counter cnt_dst_local_pre {
    comment "prerouting dst local bypass"
  }

  counter cnt_prerouting_socket_transparent {
    comment "prerouting tcp socket transparent 1"
  }

  chain prerouting {
    type filter hook prerouting priority mangle; policy accept;

    ct direction reply counter return

    fib daddr type local meta l4proto { tcp, udp } th dport $TPROXY_PORT \
      log prefix "prohibit connect to tproxy directly. " \
      reject with icmpx type host-unreachable \
      comment "prohibit connect to tproxy port directly, avoid loop"

    udp dport 53 log prefix "dns prerouting(v3): "

    #meta iif != lo
    meta l4proto { tcp, udp } th dport 53 \
      tproxy to :$TPROXY_PORT log prefix "proxy: any dns query: " \
      accept


    #counter debug
    fib daddr type local counter name cnt_dst_local_pre accept comment "bypass: local dst"

    ip daddr @dst_bypass accept comment "bypas prerouting: dst ipv4."
    ip6 daddr @dst_bypass6 accept comment "bypass prerouting: dst ipv6."

    ip saddr @src_bypass accept comment "bypass prerouting: src ipv4"

    #优化，已经是透明连接的请求不要再丢到透明代理。
    #这个socket是内核提供的数据包原始socket信息。
    #它是本机发起的对外连接的socket，它被rule7 打上标记后被重新路由到本机(路由表中设置了由lo进入)。
    meta l4proto tcp socket transparent 1 \
      counter log prefix "prerouting socket transparent: " accept

    #mark 是meta mark的简写
    meta l4proto tcp socket transparent 1 counter
    meta l4proto { tcp, udp } mark 0 mark set $PROXY_FWMARK counter
    meta l4proto { tcp, udp } mark != $PROXY_FWMARK counter accept comment "ignore other marks' packet"

    #这里的mark set 是为了外部流经的数据包(我们是router!!)，不是为了output的数据包.
    meta l4proto { tcp, udp } meta mark $PROXY_FWMARK tproxy to :$TPROXY_PORT \
      counter log prefix "intercept prerouting: default. " \
      comment "proxy"

  }

  chain output {
    type route hook output priority mangle; policy accept;

    # 这时优化：确定是发往外部的数据包直接通过
    # oifname != $OUTPUT_INTERFACE accept comment "放行到任何其它设备的流量"

    fib daddr type local \
      log prefix "bypass: output local dst: " \
      accept \
      comment "bypass: local dst"

    ip daddr @dst_bypass accept comment "bypass: dst ipv4: "
    ip6 daddr @dst_bypass6 accept comment "bypass: dst ipv6: "

    udp dport { netbios-ns, netbios-dgm, netbios-ssn } accept comment "bypass: nbns ports: "

    meta mark $OUT_MARK log prefix "bypass: proxy server: " \
      accept comment "bypass: proxy server!"

    #rule6: 本机发起对外的DNS请求重新路由
    meta l4proto { tcp, udp } th dport 53 meta mark set $PROXY_FWMARK \
      log prefix "intercept: out dns: " \
      accept comment "intercept dns query from local"

    #rule7
    meta l4proto { tcp, udp } meta mark set $PROXY_FWMARK \
        log prefix "intercept: any output: " \
        comment "intercept output traffic"
  }
}
EOF
