let lib = import "lib.ncl" in
let addr = import "addr.ncl" in
[
  {
    tag = "dynamic-proxy",
    type = "selector",
    outbounds = [
      "shadowsocks-inner"
    ],
    default = "shadowsocks-inner",
    interrupt_exist_connections = false,
  },
  {
    tag = "shadowsocks-inner",
    type = "shadowsocks",
    method = "2022-blake3-aes-128-gcm",
    multiplex = {
      enabled = true, #复用连接，而不是每次都建新连接
    },
    password = lib.placeholder "main-password",
    detour = "out-shadowtls", # 绕道到shadowtls进行包装传输
  },
  (
    {
      tag = "out-shadowtls",
      type = "shadowtls",
      version = 3,
      server | default = "127.0.0.1",
      server_port = 443,
      password = lib.placeholder "main-password",
      tls = {
        enabled = true,
        server_name = lib.placeholder "sing-box/shadowtls/server_name",
        utls = { enabled = true, fingerprint = "chrome", },
      },
    }
    & addr.proxy_server
  ),
  (
    {
      tag = "out-ss",
      type = "shadowsocks",
      server | default = "127.0.0.1",
      server_port = 80,
      method = "2022-blake3-aes-128-gcm",
      password = lib.placeholder "main-password",
      plugin = "v2ray-plugin",
      plugin_opts = "client;%{lib.placeholder "v2ray-plugin/opts"}",
      network = "tcp",
      udp_over_tcp = true,
    }
    & addr.proxy_server
  ),
  {
    tag = "out-named-server-example",
    type = "socks",
    server = "example.org",
    server_port = 2080,
    domain_resolver = {
      server = "dns-internal-ipv4",
      rewrite_ttl = 60,
    },
    # or "domain_resolver" = "dns-internal-ipv4",
    # or global route config like `{route.default_domain_resolver = "local"}`
  },
  {
    tag = "out-direct",
    type = "direct",
  }
]
