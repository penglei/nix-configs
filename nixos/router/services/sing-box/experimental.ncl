{
  gatewayAddr | not_exported | default = "0.0.0.0", #"[::1]",
  clash_api = {
    external_controller = "%{gatewayAddr}:18180", #netaddr.ipv4.gateway
    external_ui = "ui",
    external_ui_download_url = "https://github.com/MetaCubeX/Yacd-meta/archive/gh-pages.zip",
    external_ui_download_detour = "bootstrap-proxy",
  },
  cache_file = {
    enabled = true
  },
}
