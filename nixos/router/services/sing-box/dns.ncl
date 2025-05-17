#❯ dig ipv6.google.com AAAA @127.0.0.1 -p 29753
#❯ dig +noedns +qr +retry=0 @127.0.0.1 -p 29753 www.google.com

##chinese mainland
#❯ dig +subnet=222.210.108.0/24 @127.0.0.1 -p 29753 www.qq.com
#❯ dig +tcp +subnet=222.210.108.0/24 @9.9.9.9 www.qq.com
##abroad
#❯ dig +tcp +subnet=49.51.199.0/24 @9.9.9.9 www.qq.com
#❯ dig +subnet=49.51.199.0/24 @127.0.0.1 -p 29753 www.qq.com

#google-dns ecs description: https://developers.google.com/speed/public-dns/docs/ecs
#> Note: ECS responses MUST match the ECS address family, address, and source prefix length of the corresponding queries.
#> If they do not, the name server does not correctly implement ECS, and Google Public DNS may not send ECS queries to it.
#The following queries have no response(in a host located in 43.135.87.0/24):
#❯ dig +subnet=222.210.108.0/20 ipv6.google.com AAAA @8.8.8.8
#> but it works on the same subnet:
#❯ dig +subnet=43.135.87.0/24 ipv6.google.com AAAA @8.8.8.8
#It's maybe that google authoriate server has rejected resolving from chinese mainland?
# But it works if subnet is ipv6:
#❯ dig +subnet=240e:39f:9:6a3a::/56 ipv6.google.com AAAA @8.8.8.8

#quad9 has no limit
#❯ dig +tcp +subnet=222.210.108.0/24 ipv6.google.com AAAA @9.9.9.9
fun value =>
  let addr = import "./addr.ncl" in
  let dns_debug_names = ["www.qq.com", "www.baidu.com", ] in
  let _debug_client_subnet_rules = [
    #debugging edns0-subnet
    {
      type = "logical",
      mode = "and",
      rules = [
        { domain = dns_debug_names },
        { inbound = "in-dnsserver(::1)" },
      ],
      server = "abroad-dns",
    },
    {
      type = "logical",
      mode = "and",
      rules = [
        { domain = dns_debug_names },
        { inbound = "in-dnsserver(127.0.0.1)" },
      ],
      server = "cn-dns",
    },
  ]
  in
  {
    #servers是特殊的dns outbound
    servers =
      #_debug_client_subnet_rules @ #
      [
        # {
        #   tag = "cn-dns",
        #   type = "https",
        #   server = value.china_dns,
        #   server_port = 443,
        #   path = "/dns-query", #default

        #   ##Deprecated: detour to an empty direct outbound makes no sense
        #   #detour = "out-direct",
        # },
        {
          tag = "cn-dns",
          type = "udp",
          server = value.china_dns,
        },
        {
          tag = "abroad-dns",
          type = "https",
          #"dns.google", #8.8.8.8,8.8.4.4,2001:4860:4860::8888,2001:4860:4860::8844
          server = "dns.quad9.net", #9.9.9.9,149.112.112.112
          server_port = 443,
          # path = "/dns-query", #default
          domain_resolver = "cn-dns", # 建连接前resolver自身的域名需要先解析好。

          detour = "dns-proxy", #dns请求本身走国外
        },

        #代理内部使用的dns resolver，可提供给sing-box进程内使用，如:
        #rule resolve action 或  outbound domain_resolver 。
        #这个server tag只是一个占位符，用以表达**sing-box内部Resolver服务**，
        #任何dns rules 不得将流量转发到该server，
        #否则解析过程会形成loop。
        {
          tag = "dns-internal",
          type = "udp",
          server = "127.0.0.1",
          server_port = addr.self_dns, #必须在inbound中配置该服务。
        },
      ],
    rules = [
      { rule_set = "dns-direct", action = "route", server = "cn-dns" },

      ##无论用什么模式，至少应该保证dns解析正确，否则错误的解析还是影响网络访问的连通性。
      #{ clash_mode = "direct", server = "cn-dns", },
      #{ clash_mode = "global", server = "abroad-dns" },

      # 手动配置直连的域名并不一定要走国内的DNS，海外解析更准确，但是直连速度却更快。
      # { rule_set = "site-direct", action = "route", server = "cn-dns" },
      # 明确走代理的网站也用国外的DNS解析
      { rule_set = "site-proxy", server = "abroad-dns" },

      # # 屏蔽广告DNS解析
      # {
      #   rule_set = "geosite-category-ads-all",
      #   action = "reject",
      #   method = "default", #reject option
      # },

      # 国内域名或者位于国内，用国内dns
      {
        "rule_set" = ["geosite-cn", "geosite-geolocation-cn"],
        "server" = "cn-dns"
      },
      {
        type = "logical",
        mode = "and",
        rules = [
          { rule_set = "geosite-geolocation-!cn", invert = true },
          { rule_set = "geoip-cn" }
        ],
        server = "abroad-dns",
      },
    ],

    final = "abroad-dns",

    client_subnet = "222.210.108.0/24", #default edns0-subnet #成都
    strategy = "prefer_ipv4", #"ipv4_only"

    #Stores a reverse mapping of IP addresses after responding to a DNS query
    #in order to provide domain names when routing.
    #If we serve as a transparent proxy, routes' rule has no information about
    #request domain metadata. This option will populate the domain metadata by
    #doing reversing query from the store.
    reverse_mapping = true,

    disable_cache = false,
    cache_capacity = 50000,
  }
