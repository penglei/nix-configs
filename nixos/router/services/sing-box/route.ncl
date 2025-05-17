# The default rule uses the following matching logic:
# (domain || domain_suffix || domain_keyword || domain_regex || geosite || geoip || ip_cidr || ip_is_private) &&
# (port || port_range) &&
# (source_geoip || source_ip_cidr || source_ip_is_private) &&
# (source_port || source_port_range) &&
# other fields
let proxy_rules = {
  type = "logical",
  mode = "or",
  rules = [
    #非国内域名、明确指定的域名或IP
    { rule_set = ["geosite-geolocation-!cn", "site-proxy", "ip-proxy"] },
    #非国内IP
    { rule_set = "geoip-cn", invert = true },
  ],
}
in
{
  rules = [
    #Action
    #"action" field is an enum type, which can be:
    #  "route"            #default, next to outbound
    #  "reject"           #obvious
    #  "hijack-dns"       #劫持DNS请求
    #  "route-options"    #? add more information?
    #  "sniff"            #sniff protocol
    #  "resolve"          #resolve request destination from carried domain to IP addresse
    #  "direct"           #direct
    #

    # ##for developing
    # {
    #   inbound = "mixed-proxy",
    #   outbound = "relay-to-sv-alpha",
    # },

    #performs protocol, domain and client sniffing
    #大部分流量都能嗅探出域名，所以其实很少需要reverse_mapping 来resolve连接的域名。
    { action = "sniff" },

    #Only hijack dns request from explicit inbounds(dns server).
    {
      type = "logical",
      mode = "and",
      rules = [
        {
          type = "logical",
          mode = "or",
          rules = [
            { inbound = "in-dnsserver(127.0.0.1)" },
            { inbound = "in-dnsserver(::1)" },
          ]
        },
        { protocol = "dns" },
      ],
      action = "hijack-dns" #The dns request will be routed by dns.route.
    },

    # Maybe we can override destination ip to ipv6 for geo determination
    # #Internally resolve destination from domain to IP addresses.
    # #If the inbound is a proxy protocol such as SOCKS5, HTTP_PROXY,
    # #or others that carry domain information, DNS resolution can be
    # #performed at an early stage. This allows subsequent rules to
    # #make decisions based on the geographical attributes of the internal resolved IP address.
    # {
    #   action = "resolve",
    #   strategy = "ipv4_only", #"prefer_ipv4",   #dns.strategy will be used by default
    #   server = "dns-internal",
    # },

    ###split traffic

    #clash控制面板(路由器上没必要支持):
    #   不选择直连时，全部不代理;
    #   选择“全局”代理时，全部走指定代理
    # { clash_mode = "direct", outbound = "out-direct" },
    # { clash_mode = "global", outbound = "MY-XXX-PROXY" },

    #特殊的站点、协议直连
    {
      type = "logical",
      mode = "or",
      rules = [
        {
          rule_set = [
            "site-direct",
            "ip-direct"

            # 数据源不准确，e.g. 包含了很多google的域名
            # "geoip-cn", "geosite-cn"
          ]
        },
        { protocol = ["bittorrent"] },
      ],
      outbound = "out-direct"
    },

    #代理IPv4
    {
      type = "logical",
      mode = "and",
      rules = [
        { ip_version = 4 },
        proxy_rules,
      ],
      outbound = "ipv4-proxy"
    },

    #代理 IPv6
    {
      type = "logical",
      mode = "and",
      rules = [
        { ip_version = 6 },
        proxy_rules,
      ],
      outbound = "ipv6-proxy"
    },
  ],
  final = "out-direct", #Default outbound tag. the first outbound will be used if empty.

  #默认为出站连接设置路由标记，如果设置了 `outbound.routing_mark` 设置，则不生效。
  default_mark = 666,

  #default dial `domain_resolver` field. See Dial Fields for details.
  default_domain_resolver = "cn-dns",

  #Bind outbound connections to the default NIC by default to prevent routing loops under tun.
  auto_detect_interface = true,
  #or
  ##Bind outbound connections to the specified NIC by default to prevent routing loops under tun
  #default_interface = "pppoe-wan",
}
