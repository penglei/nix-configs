{
  version = 1,
  rules = [
    {
      domain = [
        #https://docs.netbird.io/about-netbird/faq#outgoing-ports
        "api.netbird.io",
        "signal.netbird.io",
        "turn.netbird.io",
        "stun.netbird.io",
        "relay.netbird.io",
      ],
      domain_suffix = [
        #❯ curl https://test.ipw.cn/
        ".cn",
        ".relay.netbird.io",
      ],
    }
  ]
}
