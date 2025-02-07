#!/usr/bin/env bash

set -euo pipefail
#OUTPUT_INTERFACE=$(ip route show default | awk '/default/ {print $5}')
OUTPUT_INTERFACE="pppoe-wan"

TPROXY_PORT=11911 ## same as sing-box inbound
ROUTING_MARK=666  ## https://sing-box.sagernet.org/configuration/route/#default_mark
PROXY_FWMARK=119

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
      0.0.0.0/8, 10.0.0.0/8, 100.64.0.0/10, 127.0.0.0/8, 169.254.0.0/16, 172.16.0.0/12, 192.0.0.0/24, 192.0.2.0/24,
      192.31.196.0/24, 192.52.193.0/24, 192.88.99.0/24, 192.168.0.0/16, 192.175.48.0/24, 198.18.0.0/15, 198.51.100.0/24,
      203.0.113.0/24, 224.0.0.0/4, 240.0.0.0/4, 255.255.255.255,
    }
  }

  set dst_bypass6 {
    typeof ip6 daddr
    flags interval
    auto-merge
    elements = {
      ::1/128, ::/128, ::ffff:0:0/96, 64:ff9b:1::/48, 100::/64, 2001:2::/48, 2001:db8::/32, fe80::/10, 2001::/23, fc00::/7,
    }
  }

  # 我们透明代理是尽量forward，一般不需要单独配置forward的场景。
  # 除非哪天我们优化性能，将一些dst bypass的判断offload到nftables中出现误判时，
  # 才需要手动修正。
  # set dst_forward {}

  chain prerouting {
    type filter hook prerouting priority mangle; policy accept;

    ip saddr 192.168.202.2 udp dport 53 log prefix "prerouting sing-box tproxy:AAAA:";

    #DNS自动转发到代理进行处理。我们在这里没有这么做，因为在router上启用了systemd-resolved作为DNS代理缓存。
    meta l4proto { tcp, udp } th dport 53 tproxy to :$TPROXY_PORT accept comment "proxy any dns query"

    ip saddr 192.168.202.2 udp dport 53 log prefix "prerouting sing-box tproxy:BBBB:";

    fib daddr type local meta l4proto { tcp, udp } th dport $TPROXY_PORT \
      reject with icmpx type host-unreachable \
      comment "prohibit connect to tproxy port directly, avoid loop"

    ip saddr 192.168.202.2 udp dport 53 log prefix "prerouting sing-box tproxy:CCCC:";

    ip daddr @dst_bypass accept comment "prerouting: dst bypass ipv4"
    ip6 daddr @dst_bypass6 accept comment "prerouting: dst bypass ipv6"

    ip saddr 192.168.202.2 udp dport 53 log prefix "prerouting sing-box tproxy:DDDD:";

    ip saddr @src_bypass accept comment "prerouting: src bypass ipv4"

    fib daddr type local accept comment "local bypass"

    ip saddr 192.168.202.2 udp dport 53 log prefix "prerouting sing-box tproxy:EEEE:";

    meta l4proto tcp socket transparent 1 meta mark set $PROXY_FWMARK accept comment "pass established connection"

    ip saddr 192.168.202.2 udp dport 53 log prefix "prerouting sing-box tproxy:FFFF:";

    meta l4proto { tcp, udp } tproxy to :$TPROXY_PORT meta mark set $PROXY_FWMARK \
      log prefix "!!!proxy to singbox:" \
      comment "proxy"

    ip saddr 192.168.202.2 udp dport 53 log prefix "prerouting sing-box tproxy:GGGG:";
  }

  chain output {
    type route hook output priority mangle; policy accept;

    #rule1: 放行到其它设备的流量，这包含local和remote，但是到output interface的流量全部要去后面判断。
    # oifname != $OUTPUT_INTERFACE accept comment "放行到任何其它设备的流量"

    #rule2: 放行目的地址为local(即本机某个IP)的所有流量。
    #       如果不加这一条，本地通过OUTPUT_INTERFACE地址访问*本地53端口*会被拦截进行重新路由。参见rule6。
    fib daddr type local accept comment "bypass to local"

    ip daddr @dst_bypass accept comment "out: dst bypass ipv4"
    ip6 daddr @dst_bypass6 accept comment "out: dst bypass ipv6"

    udp dport { netbios-ns, netbios-dgm, netbios-ssn } accept comment "bypass nbns ports"

    meta mark $ROUTING_MARK accept comment "allow to proxy server (real stream!!)"

    #rule6: 本机发起对外的DNS请求重新路由
    #在output链上，meta匹配的一定是本机发起的访问。但如果访问的是本地地址，会怎么样？前面的rule已经放行了。
    meta l4proto { tcp, udp } th dport 53 meta mark set $PROXY_FWMARK accept comment "intercept dns query from local"

    meta l4proto { tcp, udp } meta mark set $PROXY_FWMARK \
        comment "intercept output traffic" \
        #log prefix "intercept outout: sing-box tproxy"
  }
}
EOF
