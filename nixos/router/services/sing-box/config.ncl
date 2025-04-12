{
  dns = import "./dns.ncl",
  inbounds = import "./inbounds.ncl",
  outbounds = import "./outbounds.ncl",
  route = import "./route.ncl",
  route.rule_set = import "./rule_set.ncl",
  experimental = import "./experimental.ncl",
  log = {
    timestamp = true,
    level = "debug",
  },
}
