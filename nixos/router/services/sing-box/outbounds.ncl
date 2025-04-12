let lib = import "lib.ncl" in
let addr = import "addr.ncl" in
[
  {
    tag = "dynamic-proxy",
    type = "selector",
    outbounds = [
      #hk-alpha server
      "out-hk-alpha-ss-on-shadowtls",

      #sv-alpha server
      "out-sv-alpha-ss-on-shadowtls",
      "out-sv-alpha-ss",

      #subscribe
      "out-subscribe-a",
      "out-clashcloud-ss",
    ],
    default = "out-clashcloud-ss",
    interrupt_exist_connections = false,
  },

  ##{
  {
    tag = "out-hk-alpha-ss-on-shadowtls",
    type = "shadowsocks",
    method = "2022-blake3-aes-128-gcm",
    multiplex = {
      enabled = true, #复用连接，而不是每次都建新连接
    },
    password = lib.placeholder "main-password",
    detour = "out-hk-alpha-shadowtls", # 绕道进行shadowtls包装传输
  },
  {
    tag = "out-hk-alpha-shadowtls",
    type = "shadowtls",
    version = 3,
    server = lib.placeholder "sing-box/hk-alpha/address",
    server_port = 443,
    password = lib.placeholder "main-password",
    tls = {
      enabled = true,
      server_name = lib.placeholder "sing-box/hk-alpha/shadowtls/server_name",
      utls = { enabled = true, fingerprint = "chrome", },
    },
  },
  ##}

  ##{sv-alpha provides ipv6
  {
    tag = "out-sv-alpha-ss-on-shadowtls",
    type = "shadowsocks",
    method = "2022-blake3-aes-128-gcm",
    multiplex = {
      enabled = true, #复用连接，而不是每次都建新连接
    },
    password = lib.placeholder "main-password",
    detour = "out-sv-alpha-shadowtls", # 绕道进行shadowtls包装传输
  },
  (
    {
      tag = "out-sv-alpha-shadowtls",
      type = "shadowtls",
      version = 3,
      server | default = "127.0.0.1",
      server_port = 443,
      password = lib.placeholder "main-password",
      tls = {
        enabled = true,
        server_name = lib.placeholder "sing-box/sv-alpha/shadowtls/server_name",
        utls = { enabled = true, fingerprint = "chrome", },
      },
    }
    & addr.proxy_server.sv-alpha
  ),
  (
    {
      tag = "out-sv-alpha-ss",
      type = "shadowsocks",
      server | default = "127.0.0.1",
      server_port = 80,
      method = "2022-blake3-aes-128-gcm",
      password = lib.placeholder "main-password",
      plugin = "v2ray-plugin",
      plugin_opts = "client;%{lib.placeholder "sing-box/sv-alpha/v2ray-plugin/opts"}",
      network = "tcp",
      udp_over_tcp = true,
    }
    & addr.proxy_server.sv-alpha
  ),
  ##}
  {
    tag = "out-direct",
    type = "direct",
  }
]
@ (import "./subscribes/a.ncl")
