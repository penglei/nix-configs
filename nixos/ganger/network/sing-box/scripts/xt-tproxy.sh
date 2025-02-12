#proxy-rules \
#         -l 1100 \
#         -L 1100 \
#        --local-default forward \
#        --src-default checkdst \
#        -s 119.28.137.223 \
#        --dst-default forward \
#        --dst-bypass-file /etc/cidr_cn.txt

__errmsg() {
  echo "proxy-rules: $*" >&2
}

if [ "$1" = "-6" ]; then
  if ! ip6tables -t nat -L -n &>/dev/null; then
    __errmsg "Skipping ipv6.  Requires ip6tables-mod-nat"
    exit 1
  fi
  o_use_ipv6=1
  shift
fi

proxy_rules_usage() {
  cat >&2 <<EOF
Usage: proxy-rules [options]

	-6              Operate on address family IPv6
	                When present, must be the first argument
	-h, --help      Show this help message then exit
	-f, --flush     Flush rules, ipset then exit
	-l <port>       Local port number of proxy with TCP mode
	-L <port>       Local port number of proxy with UDP mode
	-s <ips>        List of ip addresses of remote proxy server
	--ifnames       Only apply rules on packets from these ifnames
	--ipt-extra     extra iptable rule when dealing prerouting/output traffic
	--src-bypass <ips|cidr>
	--src-forward <ips|cidr>
	--src-checkdst <ips|cidr>
	--src-default <bypass|forward|checkdst>
	                Packets will have their src ip checked in order against
	                bypass, forward, checkdst list and will bypass, forward
	                through, or continue to have their dst ip checked
	                respectively on the first match.  Otherwise, --src-default
	                decide the default action
	--dst-bypass <ips|cidr>
	--dst-forward <ips|cidr>
	--dst-bypass-file <file>
	--dst-forward-file <file>
	--dst-default <bypass|forward>
	                Same as with their --src-xx equivalent
	--dst-forward-recentrst
	                Forward those packets whose destinations have recently
	                sent to us multiple tcp-rst packets
	--local-default <bypass|forward|checkdst>
	                Default action for local out TCP traffic

The following ipsets will be created by proxy-rules.  They are also intended to be
populated by other programs like dnsmasq with ipset support

	proxy_rules_src_bypass
	proxy_rules_src_forward
	proxy_rules_src_checkdst
	proxy_rules_dst_bypass
	proxy_rules_dst_forward
EOF
}

o_dst_bypass4_="
	0.0.0.0/8
	10.0.0.0/8
	100.64.0.0/10
	127.0.0.0/8
	169.254.0.0/16
	172.16.0.0/12
	192.0.0.0/24
	192.0.2.0/24
	192.31.196.0/24
	192.52.193.0/24
	192.88.99.0/24
	192.168.0.0/16
	192.175.48.0/24
	198.18.0.0/15
	198.51.100.0/24
	203.0.113.0/24
	224.0.0.0/4
	240.0.0.0/4
	255.255.255.255
"
o_dst_bypass6_="
	::1/128
	::/128
	::ffff:0:0/96
	64:ff9b:1::/48
	100::/64
	2001:2::/48
	2001:db8::/32
	fe80::/10
	2001::/23
	fc00::/7
"
o_src_default=bypass
o_dst_default=bypass
o_local_default=bypass

#alias grep_af="sed -ne '/:/!p'"
grep_af_pattern='/:/!p'
o_dst_bypass_="$o_dst_bypass4_"
if [ -n "$o_use_ipv6" ]; then
  grep_af_pattern='/:/p'
  #alias grep_af="sed -ne /:/p"
  alias iptables=ip6tables
  alias iptables-save=ip6tables-save
  alias iptables-restore=ip6tables-restore
  alias ip="ip -6"
  o_af=6
  o_dst_bypass_="$o_dst_bypass6_"
fi

proxy_rules_parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
    -h | --help)
      proxy_rules_usage
      exit 0
      ;;
    -f | --flush)
      proxy_rules_flush
      exit 0
      ;;
    -l)
      o_redir_tcp_port="$2"
      shift 2
      ;;
    -L)
      o_redir_udp_port="$2"
      shift 2
      ;;
    -s)
      o_remote_servers="$2"
      shift 2
      ;;
    --ifnames)
      o_ifnames="$2"
      shift 2
      ;;
    --ipt-extra)
      o_ipt_extra="$2"
      shift 2
      ;;
    --src-default)
      o_src_default="$2"
      shift 2
      ;;
    --dst-default)
      o_dst_default="$2"
      shift 2
      ;;
    --local-default)
      o_local_default="$2"
      shift 2
      ;;
    --src-bypass)
      o_src_bypass="$2"
      shift 2
      ;;
    --src-forward)
      o_src_forward="$2"
      shift 2
      ;;
    --src-checkdst)
      o_src_checkdst="$2"
      shift 2
      ;;
    --dst-bypass)
      o_dst_bypass="$2"
      shift 2
      ;;
    --dst-forward)
      o_dst_forward="$2"
      shift 2
      ;;
    --dst-forward-recentrst)
      o_dst_forward_recentrst=1
      shift 1
      ;;
    --dst-bypass-file)
      o_dst_bypass_file="$2"
      shift 2
      ;;
    --dst-forward-file)
      o_dst_forward_file="$2"
      shift 2
      ;;
    *)
      __errmsg "unknown option $1"
      return 1
      ;;
    esac
  done

  if [ -z "$o_redir_tcp_port" ] && [ -z "$o_redir_udp_port" ]; then
    __errmsg "Requires at least -l or -L option"
    return 1
  fi
  if [ -n "$o_dst_forward_recentrst" ] && ! iptables -m recent -h >/dev/null; then
    __errmsg "Please install iptables-mod-conntrack-extra"
    return 1
  fi
  o_remote_servers="$(for s in $o_remote_servers; do resolveip "$s" | sed -n "$grep_af_pattern"; done)"
}

rt_name="tproxy"
proxy_rules_flush() {
  local setname

  #clear iptables
  iptables-save --counters | grep -v proxy_rules_ | iptables-restore --counters

  #clear routing
  while ip rule del fwmark 1 table $rt_name 2>/dev/null; do true; done
  local exist_rt
  exist_rt=$(ip route show table all | grep "table" | sed 's/.*\(table.*\)/\1/g' | awk '{print $2}' | sort | uniq | grep "^$rt_name$")
  if [ -n "$exist_rt" ]; then
    ip route flush table $rt_name
  fi

  #clear ipset
  for setname in $(ipset -n list | grep "proxy_rules${o_af}_"); do
    ipset destroy "$setname" 2>/dev/null || true
  done
}

proxy_rules_ipset_init() {
  ipset --exist restore <<-EOF
		create proxy_rules${o_af}_src_bypass hash:net family inet$o_af hashsize 64
		create proxy_rules${o_af}_src_forward hash:net family inet$o_af hashsize 64
		create proxy_rules${o_af}_src_checkdst hash:net family inet$o_af hashsize 64
		create proxy_rules${o_af}_dst_bypass hash:net family inet$o_af hashsize 64
		create proxy_rules${o_af}_dst_bypass_ hash:net family inet$o_af hashsize 64
		create proxy_rules${o_af}_dst_forward hash:net family inet$o_af hashsize 64
		create proxy_rules${o_af}_dst_forward_rrst_ hash:ip family inet$o_af hashsize 8 timeout 3600
		$(proxy_rules_ipset_mkadd "proxy_rules${o_af}_dst_bypass_" "$o_dst_bypass_ $o_remote_servers")
		$(proxy_rules_ipset_mkadd "proxy_rules${o_af}_src_bypass" "$o_src_bypass")
		$(proxy_rules_ipset_mkadd "proxy_rules${o_af}_src_forward" "$o_src_forward")
		$(proxy_rules_ipset_mkadd "proxy_rules${o_af}_src_checkdst" "$o_src_checkdst")
		$(proxy_rules_ipset_mkadd "proxy_rules${o_af}_dst_bypass" "$o_dst_bypass $(cat "$o_dst_bypass_file" 2>/dev/null)")
		$(proxy_rules_ipset_mkadd "proxy_rules${o_af}_dst_forward" "$o_dst_forward $(cat "$o_dst_forward_file" 2>/dev/null)")
	EOF
}

proxy_rules_ipset_mkadd() {
  local setname="$1"
  shift
  local i

  for i in "$@"; do
    echo "add $setname $i"
  done | sed -n "$grep_af_pattern"
}

proxy_rules_iptchains_init() {
  local src_default_target dst_default_target
  local recentrst_mangle_rules recentrst_addset_rules

  echo -e "1\t$rt_name" >/etc/iproute2/rt_tables.d/proxy.conf
  ip route add local default dev lo scope host table $rt_name #set default route for traffic which target to 'local' to 'dev lo'
  ip rule add fwmark 1 table $rt_name                         #proxy route rule

  if [ -n "$o_dst_forward_recentrst" ]; then
    recentrst_mangle_rules="-I PREROUTING 1 -p tcp -m tcp --tcp-flags RST RST -m recent --name proxy_rules_recentrst --set --rsource"
    recentrst_addset_rules=$(
      cat <<EOF
-A proxy_rules_dst -m recent --name proxy_rules_recentrst --rcheck --rdest --seconds 3 --hitcount 3 -j SET --add-set proxy_rules${o_af}_dst_forward_rrst_ dst --exist
-A proxy_rules_dst -m set --match-set proxy_rules${o_af}_dst_forward_rrst_ dst -j proxy_rules_forward
EOF
    )
  fi

  local forward_rule_tcp
  if [ -n "$o_redir_tcp_port" ]; then
    forward_rule_tcp="-A proxy_rules_forward -p tcp -j TPROXY --on-port $o_redir_tcp_port --on-ip 127.0.0.1 --tproxy-mark 0x01/0x01"
  fi
  local forward_rule_udp
  if [ -n "$o_redir_udp_port" ]; then
    forward_rule_udp="-A proxy_rules_forward -p udp -j TPROXY --on-port $o_redir_udp_port --on-ip 127.0.0.1 --tproxy-mark 0x01/0x01"
  fi

  case "$o_src_default" in
  forward) src_default_target=proxy_rules_forward ;;
  checkdst) src_default_target=proxy_rules_dst ;;
  bypass | *) src_default_target=RETURN ;;
  esac
  case "$o_dst_default" in
  forward) dst_default_target=proxy_rules_forward ;;
  bypass | *) dst_default_target=RETURN ;;
  esac

  local local_target=''
  case "$o_local_default" in
  checkdst) local_target=proxy_rules_local_dst ;;
  forward) local_target=proxy_rules_local_forward ;;
  bypass | *) ;;
  esac

  if [ -n "$local_target" ]; then
    local_output_rules="
			-A proxy_rules_local_out -m set --match-set proxy_rules${o_af}_dst_bypass_ dst -j RETURN
			-A proxy_rules_local_out $o_ipt_extra -j $local_target
			-A proxy_rules_local_dst -m set --match-set proxy_rules${o_af}_dst_forward dst -j proxy_rules_local_forward
			-A proxy_rules_local_dst -m set --match-set proxy_rules${o_af}_dst_bypass dst -j RETURN
			-A proxy_rules_local_forward -j MARK --set-mark 1
			-A OUTPUT -p tcp -j proxy_rules_local_out
			-A OUTPUT -p udp -j proxy_rules_local_out
		"
  fi

  local user=tproxy
  local group=tproxy
  grep -qw $user /etc/passwd || echo "$user:x:2333:2333:::" >>/etc/passwd
  grep -qw $user /etc/group || echo "$group:x:2333:$group" >>/etc/group

  sed -e '/^\s*$/d' -e 's/^\s\+//' <<-EOF | iptables-restore --noflush
		*mangle
		:proxy_rules_pre_src -
		:proxy_rules_src -
		:proxy_rules_dst -
		:proxy_rules_forward -
		:proxy_rules_local_out -
		:proxy_rules_local_dst  -
		:proxy_rules_local_forward -
		-I proxy_rules_local_out 1 -m owner --gid-owner 2333 -j RETURN
		$local_output_rules
		$(proxy_rules_iptchains_mkprerules "tcp")
		$(proxy_rules_iptchains_mkprerules "udp")
		-A proxy_rules_pre_src -m set --match-set proxy_rules${o_af}_dst_bypass_ dst -j RETURN
		-A proxy_rules_pre_src $o_ipt_extra -j proxy_rules_src
		-A proxy_rules_src -m set --match-set proxy_rules${o_af}_src_bypass src -j RETURN
		-A proxy_rules_src -m set --match-set proxy_rules${o_af}_src_forward src -j proxy_rules_forward
		-A proxy_rules_src -m set --match-set proxy_rules${o_af}_src_checkdst src -j proxy_rules_dst
		-A proxy_rules_src -j $src_default_target
		-A proxy_rules_dst -m set --match-set proxy_rules${o_af}_dst_forward dst -j proxy_rules_forward
		-A proxy_rules_dst -m set --match-set proxy_rules${o_af}_dst_bypass dst -j RETURN
		$recentrst_addset_rules
		-A proxy_rules_dst -j $dst_default_target
		$forward_rule_tcp
		$forward_rule_udp
		$recentrst_mangle_rules
		COMMIT
	EOF
}

proxy_rules_iptchains_mkprerules() {
  local proto="$1"

  if [ -z "$o_ifnames" ]; then
    echo "-I PREROUTING 1 -p $proto -j proxy_rules_pre_src"
  else
    echo "$o_ifnames" |
      tr ' ' '\n' |
      sed "s/.*/-I PREROUTING 1 -i \\0 -p $proto -j proxy_rules_pre_src/"
  fi
}

proxy_rules_parse_args "$@"
proxy_rules_flush
proxy_rules_ipset_init
proxy_rules_iptchains_init
