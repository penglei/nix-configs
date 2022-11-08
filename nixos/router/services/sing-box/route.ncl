# The default rule uses the following matching logic:
# (domain || domain_suffix || domain_keyword || domain_regex || geosite || geoip || ip_cidr || ip_is_private) &&
# (port || port_range) &&
# (source_geoip || source_ip_cidr || source_ip_is_private) &&
# (source_port || source_port_range) &&
# other fields
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
    { protocol = "bittorrent", outbound = "out-direct" },

    #兼容clash控制面板，选择“直连”时，出站流量走“out-direct”
    { clash_mode = "direct", outbound = "out-direct" },
    # #兼容clash控制面板，选择“全局”时，出站流量走“out-proxy”，即全部走代理
    # { clash_mode = "global", outbound = "xxx" }, #的路由器上没必要支持

    # Maybe we can override destination ip to ipv6 for geo determination
    # #Internally resolve destination from domain to IP addresses.
    # #If the inbound is a proxy protocol such as SOCKS5, HTTP_PROXY,
    # #or others that carry domain information, DNS resolution can be
    # #performed at an early stage. This allows subsequent rules to
    # #make decisions based on the geographical attributes of the internal resolved IP address.
    # {
    #   action = "resolve",
    #   strategy = "ipv4_only", #"prefer_ipv4",   #dns.strategy will be used by default
    #   server = "dns-internal-ipv4",
    # },
    {
      inbound = "mixed-proxy", #for developing
      outbound = "relay-to-sv-alpha",
    },

    #快速跳出指定的直连site/ip
    {
      rule_set = ["site-direct", "ip-direct"],
      outbound = "out-direct"
    },

    ###split traffic

    # rule_set数据源不准确，里面很多google的域名
    # #国内IP or 国内域名：直连
    # {
    #   #type = "default", #default
    #   ip_is_private = true,
    #   rule_set = [
    #     #如果这些rule set下载失败则不会生效。下载会受DNS影响。如果机器上的DNS异常，也没法下载成功。
    #     #最好的做法还是单独下载一份放到本地
    #     "geoip-cn",
    #     "geosite-cn"
    #   ],

    #   action = "route",
    #   outbound = "out-direct",
    #   #action = "direct"
    # },

    #非国内域名，走代理
    {
      rule_set = ["geosite-geolocation-!cn"],
      outbound = "dynamic-proxy",
    },

    #国外域名 and 非国内IP and IPv6：走支持IPv6的代理
    {
      type = "logical",
      mode = "and",
      rules = [
        # { rule_set = "geosite-geolocation-!cn" },
        { rule_set = "geoip-cn", invert = true },
        { ip_version = 6, }
      ],
      outbound = "ipv6-proxy",
    },

    # 国外域名 and 非国内IP：走代理。
    {
      type = "logical",
      mode = "and",
      rules = [
        # {
        #   rule_set = "geosite-geolocation-!cn"
        # },
        {
          rule_set = "geoip-cn",
          invert = true
        }
      ],
      outbound = "dynamic-proxy"
    },
    {
      rule_set = ["site-proxy", "ip-proxy"],
      outbound = "dynamic-proxy"
    }
  ],
  final = "out-direct", #Default outbound tag. the first outbound will be used if empty.

  #默认为出站连接设置路由标记，如果设置了 `outbound.routing_mark` 设置，则不生效。
  default_mark = 666,

  ##default dial `domain_resolver` field. See Dial Fields for details.
  #default_domain_resolver = "dns-internal",

  #Bind outbound connections to the default NIC by default to prevent routing loops under tun.
  auto_detect_interface = true,
  #or
  ##Bind outbound connections to the specified NIC by default to prevent routing loops under tun
  #default_interface = "pppoe-wan",
}
