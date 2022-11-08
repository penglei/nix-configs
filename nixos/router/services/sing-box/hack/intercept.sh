#!/usr/bin/env bash

set -euo pipefail

action="${1-start}"

debug=${DEBUG:-}

TPROXY_PORT=21012
PROXY_FWMARK=0x77

PROXY_ROUTE_TABLE=100

PROXY_NFTABLE=global-proxy

OUT_INTERFACE="pppoe-wan"

function log() {
  if [[ -n "$debug" ]]; then
    printf "%s" "log ${1}"
  fi
}

load_nft_table() {

  if nft list tables | grep -q ${PROXY_NFTABLE}; then
    nft flush table inet ${PROXY_NFTABLE}
  fi

  nft -f - <<EOF
table inet ${PROXY_NFTABLE} {

  #debug的时候临时不代理lan中的某台机器，可以加入这个set中
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

  set chnroute {
    typeof ip daddr
    flags interval
    auto-merge
  }

  set chnroute6 {
    typeof ip6 daddr
    flags interval
    auto-merge
  }

  # 透明代理会尽量将数据包forward到代理程序，而不是采用白名单的机制进行forward。
  # 将来如果需要将代理内部的判断条件offload到nftables中进行性能优化是，则可以加上
  # 根据dst、src 进行提早判断的优化。
  # set src_forward {}
  # set dst_forward {}

  counter cnt_dst_local_pre {
    comment "prerouting dst local bypass"
  }

  chain prerouting {
    #mangle hook 在conntrack之后执行，所以才能使用ct模块
    type filter hook prerouting priority mangle; policy accept;

    # meta nfproto ipv6 ip6 daddr 2404:6800:4012:8::200e $(log 'prefix "prerouting(1): "')

    ct direction reply return
    meta nfproto ipv6 return  #服务端未支持ipv6

    fib daddr type local meta l4proto { tcp, udp } th dport ${TPROXY_PORT} \
      $(log 'prefix "prohibit connect to tproxy directly. "') \
      reject with icmpx type host-unreachable \
      comment "prohibit connect to tproxy port directly, avoid loop"

    ##拦截所有DNS请求合适，即使是发往局域网内其它机器的DNS请求。
    ##暂不启用： sing-box tproxy + hijack-dns占用太多句柄，cache机制也有一些问题
    #meta l4proto { tcp, udp } th dport 53 \
    #  tproxy ip to 127.0.0.1:${TPROXY_PORT} \
    #  tproxy ip6 to [::1]:${TPROXY_PORT} \
    #  counter $(log 'prefix "proxy any dns query "') \
    #  accept
    udp dport 53 accept #TODO pass 更多必要的udp流量


    ip daddr @dst_bypass accept comment "bypass prerouting: dst ipv4."
    ip6 daddr @dst_bypass6 accept comment "bypass prerouting: dst ipv6."
    ip saddr @src_bypass accept comment "bypass prerouting: src ipv4"


    ##拦截流量:
    #方法1 (mark 是meta mark的简写)
    meta l4proto { tcp, udp } mark 0 mark set ${PROXY_FWMARK} counter comment "packets through router(maybe lo,eth)"
    meta l4proto { tcp, udp } mark != ${PROXY_FWMARK} counter accept comment "ignore other mark packet"


    ##方法2
    ##meta l4proto tcp socket transparent 1 \
    ## counter $(log 'prefix "socket transparent: "') \
    ## meta mark set ${PROXY_FWMARK} comment "fast path optimize"

    #注意需要明确的proxy address
    meta l4proto { tcp, udp } meta mark ${PROXY_FWMARK} \
      tproxy ip to 127.0.0.1:${TPROXY_PORT} \
      counter $(log 'prefix "intercept ipv4 prerouting: "') \
      accept comment "proxy"

    meta l4proto { tcp, udp } meta mark ${PROXY_FWMARK} \
      tproxy ip6 to [::1]:${TPROXY_PORT} \
      counter $(log 'prefix "intercept ipv6 prerouting: "') \
      accept comment "proxy"

  }

  chain output {
    #mangle hook 在conntrack之后执行，所以才能使用ct模块
    type route hook output priority mangle; policy accept;

    ct direction reply return

    meta l4proto udp return
    #udp dport 6881 return comment "torrent p2p remote port"
    #udp sport 51413 return comment "torrent p2p local port"

    # meta nfproto ipv6 accept  #服务端未支持ipv6

    #No IPv6 NAT is used, so there's no IPv6-based local area network, all nodes connect directly and we can't dinstict 'internal'.
    # However, as a router, we need to understand routing for home subnets.
    # Directly using dynamic IPv6 PD (Prefix Delegation) for judgment would make rule maintenance cumbersome: we need reload after pppd restarted.
    # Therefore, we take a simplified approach - assuming all internal Ethernet networks can connect directly without requiring forwarding.
    # meta nfproto ipv6 meta oif != "${OUT_INTERFACE}" accept;
    meta nfproto ipv6 oifname != "${OUT_INTERFACE}" accept;

    fib daddr type local \
      $(log 'prefix "bypass output local dst: "') \
      counter accept \
      comment "bypass: local dst"

    ip daddr @dst_bypass accept comment "bypass: dst ipv4: "
    ip daddr @chnroute accept comment "bypass: chnroute "
    ip6 daddr @dst_bypass6 accept comment "bypass: dst ipv6: "
    ip6 daddr @chnroute6 accept comment "bypass: chnroute6 "

    udp dport { netbios-ns, netbios-dgm, netbios-ssn } accept comment "bypass: nbns ports: "

    ## sing-box outbound connection
    ## SO_MARK, rules.default_mark
    ## see https://sing-box.sagernet.org/configuration/route/#default_mark
    #meta mark 666 $(log 'prefix "bypass sing-box out: "') \
    #  accept comment "bypass direct or proxy server!"

    # ## 本机发起对外的DNS请求重新路由
    # #meta oif != lo 基本可以去掉，因为rule5根据路由决策已经短路了(有没有可能local route table被搞坏了但 oif 还是正确的？)。
    # #留在这里的好处是提醒不需要提前对lo output做处理，prerouting里会统一处理。
    # meta oif != lo meta l4proto { tcp, udp } th dport 53 meta mark set ${PROXY_FWMARK} \
    #   $(log 'prefix "intercept out dns: "') \
    #   counter accept comment "intercept dns query from local"

    #rule7
    meta oif != lo meta l4proto { tcp, udp } meta mark set ${PROXY_FWMARK} \
        $(log 'prefix "intercept any output: "') \
        counter comment "intercept output traffic"

    #netfilter在output之后再次进行检查(re-route checking)。此时，我们将数据包打上PROXY_FWMARK,
    #re-route checking发现策略路配置了将数据包使用路由表PROXY_ROUTE_TABLE进行转发，
    #而路由表 PROXY_ROUTE_TABLE 中配置了默认路由，将所有数据包发送到lo接口。
    #于是，lo interface将接受到这些数据包，后续(接收方)进行正常的网路栈处理(prerouting,...)。
  }
}
EOF
}

drop_nft_table() {
  if nft list tables | grep -q ${PROXY_NFTABLE}; then
    nft delete table inet ${PROXY_NFTABLE}
  fi
}

start_intercept() {

  #  [family] [action][type][ gateway ] [table]
  ip -4 route replace local default dev lo table ${PROXY_ROUTE_TABLE}
  if ! (ip -4 rule show | grep -q ${PROXY_ROUTE_TABLE}); then
    ip -4 rule add from all fwmark ${PROXY_FWMARK} lookup ${PROXY_ROUTE_TABLE}
  fi

  ip -6 route replace local default dev lo table ${PROXY_ROUTE_TABLE}
  if ! (ip -6 rule show | grep -q ${PROXY_ROUTE_TABLE}); then
    ip -6 rule add from all fwmark ${PROXY_FWMARK} lookup ${PROXY_ROUTE_TABLE}
  fi

  #load_nft_table

}

stop_intercept() {

  # drop_nft_table

  ip -6 route del local default dev lo table $PROXY_ROUTE_TABLE || true
  if (ip -6 rule show | grep -q $PROXY_ROUTE_TABLE); then
    ip -6 rule del from all fwmark ${PROXY_FWMARK} lookup $PROXY_ROUTE_TABLE
  fi

  ip -4 route del local default dev lo table $PROXY_ROUTE_TABLE || true
  if (ip -4 rule show | grep -q $PROXY_ROUTE_TABLE); then
    ip -4 rule del from all fwmark ${PROXY_FWMARK} lookup $PROXY_ROUTE_TABLE
  fi
}

case "$action" in
start)
  start_intercept
  ;;
stop)
  stop_intercept
  ;;
esac
