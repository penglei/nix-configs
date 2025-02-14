let addr = import "./addr.ncl" in
let dns_debug_names = ["www.qq.com", "www.baidu.com", ] in
let debug_client_subnet_rules = [
  #debugging edns0-subnet
  {
    type = "logical",
    mode = "and",
    rules = [
      { domain = dns_debug_names },
      { inbound = "in-dnsserver(::1)" },
    ],
    server = "dns-abroad",
    client_subnet = "222.211.224.1/32", #it should response ip located in cn
  },
  {
    type = "logical",
    mode = "and",
    rules = [
      { domain = dns_debug_names },
      { inbound = "in-dnsserver(127.0.0.1)" },
    ],
    server = "dns-cn",
  },
]
in
{
  #servers是特殊的dns outbound
  servers =
    #debug_client_subnet_rules @ #
    [
      {
        tag = "dns-cn",
        type = "https",
        server = "120.53.53.53", #"119.29.29.29"
        server_port = 443,
        # path = "/dns-query", #default
        detour = "out-direct",
      },
      {
        tag = "dns-abroad",
        type = "https",
        server = "dns.google", #8.8.8.8, 8.8.4.4,2001:4860:4860::8888,2001:4860:4860::8844
        server_port = 443,
        # path = "/dns-query", #default
        domain_resolver = "dns-cn", # 建连接前我自己的域名(dns.google)需要先解析好。
        detour = "dynamic-proxy", #dns请求本身走国外
      },

      #代理内部使用的dns resolver，提供给rule resolve action 或者 outbound domain_resolver 使用。
      #这个server tag只是一个占位符，用以表达**sing-box内部Resolver服务**，任何dns rules 不得将流量转发到该server，
      #否则解析过程会形成loop。
      {
        tag = "dns-internal-ipv4",
        type = "udp",
        server = "127.0.0.1",
        server_port = addr.self_dns, #必须在inbound中配置该服务。
      },
      {
        type = "predefined",
        responses = [{ rcode = "REFUSED" }],
      },
    ],
  rules = [

    ## 有点没理解clash的设计思路，这个配置有用吗?
    ## 无论用什么模式，至少应该保证dns解析正确，否则错误的解析还是影响网络访问的连通性。
    ## 兼容clash控制面板，选择“直连”时用国内DNS服务器
    ##{ clash_mode = "direct", server = "dns-cn", },
    ## 兼容clash控制面板，选择“全局”时用国外DNS服务器
    ##{ clash_mode = "global", server = "dns-abroad" },
    ##

    # 手动配置直连的域名并不一定要走国内的DNS，cache.nixos.org是一个(可能的)例子:
    # 海外解析更准确，但是直连速度却更快。
    #{ rule_set = "site-direct", action = "route", server = "dns-cn" },
    # 明确走代理的网站也用国外的DNS解析
    { rule_set = "site-proxy", server = "dns-abroad" },

    # 屏蔽广告DNS解析
    {
      rule_set = "geosite-category-ads-all",
      action = "reject",
      method = "default", #reject option
    },

    # 国内域名或者位于国内，用国内dns
    {
      "rule_set" = ["geosite-cn", "geosite-geolocation-cn"],
      "server" = "dns-cn"
    },
    {
      type = "logical",
      mode = "and",
      rules = [
        { rule_set = "geosite-geolocation-!cn", invert = true },
        { rule_set = "geoip-cn" }
      ],
      server = "dns-abroad",
    },
  ],

  final = "dns-abroad",

  client_subnet = "222.211.224.1/24", #default edns0-subnet #成都
  # client_subnet = "1.0.1.10/32",
  #strategy = "prefer_ipv4",

  #Stores a reverse mapping of IP addresses after responding to a DNS query
  #in order to provide domain names when routing.
  #
  #If we serve as a transparent proxy, routes' rule has no information about
  #request domain metadata. This option will populate the domain metadata by
  #doing reversing query from the store.
  reverse_mapping = true,

  disable_cache = false,
  cache_capacity = 50000,
}
