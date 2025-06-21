let lib = import "lib.ncl" in
let hk-alpha-site = {
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
}
in
let sv-alpha-site = {
  type = "shadowtls",
  version = 3,
  server = lib.placeholder "sing-box/sv-alpha/address",
  server_port = 443,
  password = lib.placeholder "main-password",
  tls = {
    enabled = true,
    server_name = lib.placeholder "sing-box/sv-alpha/shadowtls/server_name",
    utls = { enabled = true, fingerprint = "chrome", },
  },
}
in
let ss-wrapper = {
  type = "shadowsocks",
  method = "2022-blake3-aes-128-gcm",
  multiplex = {
    enabled = true, #复用连接，而不是每次都建新连接
  },
  password = lib.placeholder "main-password",
}
in
[
  {
    #internal bootstrap proxy, e.g. download rule_set from github
    tag = "bootstrap-proxy",
    type = "selector",
    outbounds = [
      "relay-to-hk-alpha",
      "hk-alpha-ss-on-shadowtls",
      "subscribes",
    ],
    default = "relay-to-hk-alpha",
  },
  {
    tag = "dns-proxy",
    type = "selector",
    outbounds = [
      "relay-to-hk-alpha",
      "subscribes",
    ],
    default = "relay-to-hk-alpha",
  },
  {
    tag = "ipv4-proxy",
    type = "selector",
    outbounds = [
      #chains
      "relay-to-hk-alpha",
      "relay-to-sv-alpha",

      #direct subscribes
      "clashcloud-ss",
      "flowercloud-ss",

      #hk-alpha server
      "hk-alpha-ss-on-shadowtls",

      #sv-alpha server
      "sv-alpha-ss-on-shadowtls",
      "sv-alpha-ss",
    ],
    default = "relay-to-hk-alpha",
    interrupt_exist_connections = false,
  },
  {
    tag = "ipv6-proxy",
    type = "selector",
    outbounds = [
      "relay-to-hk-alpha",
      "relay-to-sv-alpha",
      "sv-alpha-ss-on-shadowtls",
      "sv-alpha-ss",
    ],
    default = "relay-to-hk-alpha",
    interrupt_exist_connections = false,
  },
  {
    tag = "subscribes",
    type = "selector",
    outbounds = [
      "flowercloud-ss",
      "clashcloud-ss",
    ],
    default = "flowercloud-ss",
    interrupt_exist_connections = false,
  },

  ##relays {
  ##debug❯ ssh -o ProxyCommand='nc -X 5 -x "[::1]:23490" %h %p' x.x.x.x uname -a
  {
    tag = "relay-to-hk-alpha",
    detour = "_chain-hk-alpha-shadowtls",
  }
  & ss-wrapper,
  {
    tag = "_chain-hk-alpha-shadowtls",
    detour = "subscribes",
  }
  & hk-alpha-site,

  ##sv-alpha
  ##debug❯
  ## host="ipv6.google.com"
  ## ipv6=2607:f8b0:4007:803::200e
  ## curl -L --socks5 "[::1]:23490" --limit-rate 4096 --resolve "ipv6.google.com.hk:443:$ipv6" --connect-to "$host:443:[$ipv6]:443" https://$host
  {
    tag = "relay-to-sv-alpha",
    detour = "_chain-sv-alpha-shadowtls",
  }
  & ss-wrapper,
  {
    tag = "_chain-sv-alpha-shadowtls",
    detour = "subscribes",
  }
  & sv-alpha-site,
  ##}

  ##hk-alpha provides ipv4 only {
  (
    {
      tag = "hk-alpha-ss-on-shadowtls",
      detour = "_out-hk-alpha-shadowtls", # 绕道进行shadowtls包装传输
    }
    & ss-wrapper
  ),
  ({ tag = "_out-hk-alpha-shadowtls" } & hk-alpha-site),
  ##}

  ##sv-alpha provides ipv6 {
  (
    {
      tag = "sv-alpha-ss-on-shadowtls",
      detour = "_out-sv-alpha-shadowtls", # 通过shadowtls包装后进行传输
    }
    & ss-wrapper
  ),
  ({ tag = "_out-sv-alpha-shadowtls" } & sv-alpha-site),
  {
    tag = "sv-alpha-ss",
    type = "shadowsocks",
    server = lib.placeholder "sing-box/sv-alpha/address",
    server_port = 80,
    method = "2022-blake3-aes-128-gcm",
    password = lib.placeholder "main-password",
    plugin = "v2ray-plugin",
    plugin_opts = "client;%{lib.placeholder "sing-box/sv-alpha/v2ray-plugin/opts"}",
    network = "tcp",
    udp_over_tcp = true,
  },
  ##}

  #direct reference
  {
    tag = "out-direct",
    type = "direct",
  }
]
@ (import "./subscribes/a.ncl")
