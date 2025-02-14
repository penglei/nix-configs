let lib = import "./lib.ncl" in
let addr = import "addr.ncl" in
let LoIPv4 = { listen | default = "127.0.0.1", .. } in
let self_dns_servers =
  #❯ dig +noedns +qr +retry=0 @127.0.0.1 -p 29753 www.google.com
  (lib.case (addr.self_dns > 0))
    [
      {
        tag = "in-dnsserver(%{listen})",
        type = "direct",
        network = "udp",
        listen | String,
        listen_port = addr.self_dns,

        #why override, for matching by route rule?
        #override_address = "1.0.0.1",
        #override_port = 53, #TODO

        # udp_timeout = "1m",
      } | LoIPv4
    ]
in
let local_mixed_servers =
  (lib.case (addr.mixed_proxy > 0))
    [
      {
        listen_port = addr.mixed_proxy,
        #socks4, socks4a, socks5, http proxy
        type = "mixed",
      } | LoIPv4
    ]
in
let tproxy_servers =
  lib.case
    (addr.tproxy > 0)
    [
      # #tproxy, redirect 是两种不同的实现透明代理的方式，
      # 在Linux上推荐tproxy，redirect 内部基于nat实现，不推荐。
      # macOS只支持redirect。
      # { type = "redirect" },
      {
        type = "tproxy",
        network = "tcp",
        # listen | default = "0.0.0.0",
        listen_port = addr.tproxy,
      } | LoIPv4,
      {
        type = "tproxy",
        network = "udp",
        # listen | default = "0.0.0.0",
        listen_port = addr.tproxy,
      } | LoIPv4,
    ]
in
let all_ipv4_servers =
  tproxy_servers
  @ local_mixed_servers
  @ self_dns_servers
in
let all_ipv6_servers =
  std.array.map
    (fun s => s & { listen | force = "::1" })
    all_ipv4_servers
in
all_ipv4_servers
