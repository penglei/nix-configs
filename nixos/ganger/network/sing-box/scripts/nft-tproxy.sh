#!/usr/bin/env bash

set -euo pipefail

## sing-box tproxy inbound
TPROXY_PORT=21012

#sing-box outbound connection
## SO_MARK, rules.default_mark
#see https://sing-box.sagernet.org/configuration/route/#default_mark
OUT_MARK=666

PROXY_FWMARK=0x77

#  [family] [action][type][ gateway ] [table]
ip -4 route replace local default dev lo table 100
if ! (ip -4 rule show | grep -q 100); then
  ip -4 rule add fwmark $PROXY_FWMARK lookup 100
fi

ip -6 route replace local default dev lo table 100
if ! (ip -6 rule show | grep -q 100); then
  ip -6 rule add fwmark $PROXY_FWMARK lookup 100
fi

#`meta` connection metadata, `l4proto` can match ipv6 packet
#`th` means "Transport Header".
#`fib` means forwarding information base

table=sb-tproxy

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

  # 透明代理是尽量将数据包forward到代理程序，而不是采用白名单的机制进行forward。
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

    ct direction reply return

    fib daddr type local meta l4proto { tcp, udp } th dport $TPROXY_PORT \
      log prefix "prohibit connect to tproxy directly. " \
      reject with icmpx type host-unreachable \
      comment "prohibit connect to tproxy port directly, avoid loop"

    # udp dport 53 log prefix "debug dns prerouting(1): " counter
    #sing-box tproxy 实现的hijack-dns占用太多句柄，cache机制也有一些问题
    ##拦截所有DNS请求合适，即使是发往局域网内其它机器的DNS请求。
    ##TODO 这需要优化，因为这会导致两头内网机器之间测试DNS服务时出现异常。
    #meta l4proto { tcp, udp } th dport 53 \
    #  tproxy ip to 127.0.0.1:$TPROXY_PORT \
    #  tproxy ip6 to [::1]:$TPROXY_PORT \
    #  log prefix "proxy: any dns query(v3.1): " \
    #  counter accept
    #udp dport 53 log prefix "debug dns prerouting(2): " counter

    udp dport 53 accept

    #counter debug
    fib daddr type local counter name cnt_dst_local_pre accept comment "bypass: local dst"

    ip daddr @dst_bypass accept comment "bypas prerouting: dst ipv4."
    ip6 daddr @dst_bypass6 accept comment "bypass prerouting: dst ipv6."

    ip saddr @src_bypass accept comment "bypass prerouting: src ipv4"

    ##mark 是meta mark的简写
    ##方法1:
    meta l4proto { tcp, udp } mark 0 mark set $PROXY_FWMARK \
      counter comment "packets through router(maybe lo,eth)"
    meta l4proto { tcp, udp } mark != $PROXY_FWMARK counter accept comment "ignore other mark packet"

    ##方法2:
    #meta l4proto tcp socket transparent 1 \
    # counter log prefix "socket transparent: " \
    # meta mark set $PROXY_FWMARK comment "fast path optimize"

    meta l4proto { tcp, udp } meta mark $PROXY_FWMARK \
      tproxy ip to 127.0.0.1:$TPROXY_PORT \
      tproxy ip6 to [::1]:$TPROXY_PORT \
      counter log prefix "intercept prerouting: default. " \
      comment "proxy"

  }

  chain output {
    #mangle hook 在conntrack之后执行，所以才能使用ct模块
    type route hook output priority mangle; policy accept;

    #rule5
    fib daddr type local \
      log prefix "bypass: output local dst: " \
      counter accept \
      comment "bypass: local dst"

    ip daddr @dst_bypass accept comment "bypass: dst ipv4: "
    ip6 daddr @dst_bypass6 accept comment "bypass: dst ipv6: "

    udp dport { netbios-ns, netbios-dgm, netbios-ssn } accept comment "bypass: nbns ports: "

    meta mark $OUT_MARK log prefix "bypass: sing-box out: " \
      accept comment "bypass direct or proxy server!"

    #rule6: 本机发起对外的DNS请求重新路由
    #meta oif != lo 基本可以去掉，因为rule5根据路由决策已经短路了(有没有可能local route table被搞坏了但 oif 还是正确的？)。
    #留在这里的好处是提醒不需要提前对lo output做处理，prerouting里会统一处理。
    meta oif != lo meta l4proto { tcp, udp } th dport 53 meta mark set $PROXY_FWMARK \
      log prefix "intercept: out dns: " \
      counter accept comment "intercept dns query from local"

    #rule7
    meta oif != lo meta l4proto { tcp, udp } meta mark set $PROXY_FWMARK \
        log prefix "intercept: any output: " \
        counter comment "intercept output traffic"

    #netfilter的在output之后进行reroute-check，当我们打上PROXY_FWMARK之后, 
    #reroute-check发现路由表100中配置了将具有该mark的数据包转发到lo的规则。
    #于是，lo interface将接受该数据包，并进行正常的网路栈处理(prerouting,...)
  }
}
EOF
