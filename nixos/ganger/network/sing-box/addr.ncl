let lib = import "./lib.ncl" in
let macos = false in

let Basic = {
  self_dns | default = 29753,
  mixed_proxy | default = 23490,
  tproxy | default = 0,
  ..
}
in

if macos then
  {
    mixed_proxy = 23490,
    proxy_server = {
      server = "127.0.0.1",
      server_port = 10443,
    },
  } | Basic
else
  {
    mixed_proxy = 0, #23490,
    tproxy = 21012,
    proxy_server = {
      server = lib.placeholder "sing-box/server/address",
      server_port = 443,
    },
  } | Basic
