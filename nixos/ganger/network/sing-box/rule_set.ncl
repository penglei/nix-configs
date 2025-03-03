[
  {
    tag = "dns-direct",
    type = "local",
    format = "source",
    path = "rule_exts/dns-direct.json"
  },
  {
    tag = "site-proxy",
    type = "local",
    format = "source",
    path = "rule_exts/site-proxy.json"
  },
  {
    tag = "site-direct",
    type = "local",
    format = "source",
    path = "rule_exts/site-direct.json"
  },
  {
    tag = "ip-proxy",
    type = "local",
    format = "source",
    path = "rule_exts/ip-proxy.json"
  },
  {
    tag = "ip-direct",
    type = "local",
    format = "source",
    path = "rule_exts/ip-direct.json"
  },
  {
    tag = "geoip-cn",
    type = "remote",
    format = "binary",
    url = "https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set/geoip-cn.srs",
    download_detour = "dynamic-proxy"
  },
  {
    tag = "geosite-cn",
    type = "remote",
    format = "binary",
    url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-cn.srs",
    download_detour = "dynamic-proxy"
  },
  {
    tag = "geosite-geolocation-cn",
    type = "remote",
    format = "binary",
    url = "https://github.com/SagerNet/sing-geosite/raw/refs/heads/rule-set/geosite-geolocation-cn.srs",
    update_interval = "2d",
    download_detour = "dynamic-proxy"
  },
  {
    tag = "geosite-geolocation-!cn",
    type = "remote",
    format = "binary",
    url = "https://github.com/SagerNet/sing-geosite/raw/refs/heads/rule-set/geosite-geolocation-!cn.srs",
    update_interval = "2d",
    download_detour = "dynamic-proxy"
  },
  {
    tag = "geosite-category-ads-all",
    type = "remote",
    format = "binary",
    url = "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/category-ads-all.srs",
    update_interval = "10d",
    download_detour = "dynamic-proxy",
  }
]
# more rules
# https://github.com/MetaCubeX/meta-rules-dat/tree/sing
