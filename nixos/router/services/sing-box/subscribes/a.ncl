let lib = import "../lib.ncl" in
[
  {
    type = "shadowsocks",
    tag = "flowercloud-ss",
    server = lib.placeholder "proxies/subscribe-a/common/server",
    server_port = lib.rawplaceholder "proxies/subscribe-a/server1/port",
    method = lib.placeholder "proxies/subscribe-a/common/method",
    password = lib.placeholder "proxies/subscribe-a/common/password",
    plugin = lib.placeholder "proxies/subscribe-a/common/plugin",
    plugin_opts = lib.placeholder "proxies/subscribe-a/common/plugin_opts",
  },
  {
    type = "shadowsocks",
    tag = "clashcloud-ss",
    server = lib.placeholder "proxies/subscribe-b/server1/addr",
    server_port = lib.rawplaceholder "proxies/subscribe-b/common/port",
    method = lib.placeholder "proxies/subscribe-b/common/method",
    password = lib.placeholder "proxies/subscribe-b/common/password",
  },
]
