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

    #Forward DNS requests to the DNS server that is automatically and lazily
    #created inside sing-box. The request will be routed by dns.route.
    { protocol = "dns", action = "hijack-dns" },

    #兼容clash控制面板，选择“直连”时，出站流量走“out-direct”
    { clash_mode = "direct", outbound = "out-direct" },
    #兼容clash控制面板，选择“全局”时，出站流量走“out-proxy”，即全部走代理
    { clash_mode = "global", outbound = "out-proxy" },

    #Resolve request destination from domain to IP addresses.
    #If the inbound is a proxy protocol such as SOCKS5, HTTP_PROXY,
    #or others that carry domain information, DNS resolution can be
    #performed at an early stage. This allows subsequent rules to
    #make decisions based on the geographical attributes of the resolved IP address.
    {
      action = "resolve",
      strategy = "prefer_ipv4", #dns.strategy will be used by default
      server = "dns-internal-ipv4",
    },

    #快速跳出指定的直连site/ip
    { rule_set = ["site-direct", "ip-direct"], "outbound" = "out-direct" },

    ###split traffic

    #国内IP或域名，直连
    {
      #type = "default", #default
      ip_is_private = true,
      rule_set = [
        #如果这些rule set下载失败则不会生效。下载会受DNS影响。如果机器上的DNS异常，也没法下载成功。
        #最好的做法还是单独下载一份放到本地
        "geoip-cn",
        "geosite-cn"
      ],

      action = "route",
      outbound = "out-direct",
      # or?
      #action = "direct"
    },

    # 域名不在国内，并且域名 IP 不在中国区，走代理
    # 对于透明代理模式，这能生效吗?
    {
      type = "logical",
      mode = "and",
      rules = [
        {
          rule_set = "geosite-geolocation-!cn"
        },
        {
          rule_set = "geoip-cn",
          invert = true
        }
      ],
      outbound = "dynamic-proxy"
    },
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
