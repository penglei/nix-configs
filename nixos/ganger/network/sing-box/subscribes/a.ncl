let lib = import "../lib.ncl" in
[
  #不支持IPv6
  {
    type = "shadowsocks",
    tag = "out-subscribe-a",
    server = lib.placeholder "proxies/subscribe-a/common/server",
    server_port = lib.rawplaceholder "proxies/subscribe-a/server1/port",
    method = lib.placeholder "proxies/subscribe-a/common/method",
    password = lib.placeholder "proxies/subscribe-a/common/password",
    plugin = lib.placeholder "proxies/subscribe-a/common/plugin",
    plugin_opts = lib.placeholder "proxies/subscribe-a/common/plugin_opts",
    domain_resolver = {
      server = "dns-internal-ipv4",
      rewrite_ttl = 60,
    },
  }
]
