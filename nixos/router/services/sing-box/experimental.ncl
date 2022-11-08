{
  gatewayAddr | not_exported | default = "0.0.0.0", #"[::1]",
  clash_api = {
    external_controller = "%{gatewayAddr}:18180", #netaddr.ipv4.gateway
    external_ui = "ui",
    external_ui_download_url = "https://github.com/MetaCubeX/Yacd-meta/archive/gh-pages.zip",
    external_ui_download_detour = "dynamic-proxy",
    # secret = "123456",
    # default_mode = "rule"
  },
  cache_file = {
    enabled = true
  },
}
