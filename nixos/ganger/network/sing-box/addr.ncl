let lib = import "./lib.ncl" in
let macos = false in

if macos then
  {
    self_dns | default = 29753,
    mixed_proxy = 23490,
    tproxy | default = 0,
    proxy_server = {
      server = "127.0.0.1",
      server_port = 10443,
    },
  }
else
  {
    self_dns | default = 29753,
    mixed_proxy = 23490,
    tproxy = 21012,
    proxy_server = {
      server = lib.placeholder "sing-box/server/address",
    },
  }
