let lib = import "./lib.ncl" in
let macos = false in

if macos then
  {
    self_dns | default = 29753,
    tproxy | default = 0,
  }
else
  {
    self_dns | default = 29753,
    tproxy = 21012,
  }
