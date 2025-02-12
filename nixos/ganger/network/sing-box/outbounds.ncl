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
    password = lib.sops_placeholder "main-password",
    detour = "out-shadowtls", # 绕道到shadowtls进行包装传输
  },
  (
    {
      tag = "out-shadowtls",
      type = "shadowtls",
      version = 3,
      password = lib.sops_placeholder "main-password",
      tls = {
        enabled = true,
        server_name = lib.sops_placeholder "sing-box/shadowtls/server_name",
        #server_name = "cache.nixos.org" #nixos网站不支持tls1.3
        utls = { enabled = true, fingerprint = "chrome", },
      },
    }
    & addr.proxy_server
  ),
  {
    tag = "out-named-server-example",
    type = "socks",
    server = "example.org",
    server_port = 2080,
    domain_resolver = {
      server = "dns-internal",
      rewrite_ttl = 60,
    },
    # or "domain_resolver" = "dns-internal",
    # or global route config like `{route.default_domain_resolver = "local"}`
  },
  {
    tag = "out-direct",
    type = "direct",
  }
]
