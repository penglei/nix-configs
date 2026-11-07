#!/usr/bin/env bash

set -euo pipefail

# 升级系统级 Nix（官方 macOS 多用户安装）。
# 首次运行：把提供 bin/nix 的元素迁移到 nixpkgs#nixVersions.latest。
# 之后每次：跟随 registry pin 做 nix profile upgrade --all。
#
# 用法：make upgrade-nix（会提示输入 sudo 密码）
# 前置：nix flake update nixpkgs && make pin-registry

# 必须操作安装器 default symlink 背后的真实 generation 链；直接对
# /nix/var/nix/profiles/default 跑 nix profile 会覆盖掉那个 symlink。
PROFILE=/nix/var/nix/profiles/per-user/root/profile
MANIFEST="$PROFILE/manifest.json"
REGISTRY="$HOME/.config/nix/registry.json"
NIXBIN="$(command -v nix || true)"

die() { echo "error: $*" >&2; exit 1; }

[[ -n "$NIXBIN" ]] || die "找不到 nix；先恢复 symlink：sudo ln -sfn $PROFILE /nix/var/nix/profiles/default"
[[ -r "$REGISTRY" ]] || die "缺少 $REGISTRY，先跑 make pin-registry"
[[ -r "$MANIFEST" ]] || die "读不到 $MANIFEST"

sudo -v

# root 读不到用户级 registry，显式指定后才能离线解析 flake:nixpkgs
opts=(--option flake-registry "$REGISTRY")

# 判断迁移状态用 manifest.json（nix profile list 的元素名带 ANSI 转义）
if jq -e 'any(.elements[].attrPath; test("nixVersions\\.latest"))' "$MANIFEST" >/dev/null; then
	echo "==> 常规升级：upgrade --all"
	sudo -H "$NIXBIN" "${opts[@]}" profile upgrade --all --profile "$PROFILE"
else
	echo "==> 首次迁移：安装 nixpkgs#nixVersions.latest"
	# 不先 remove：install 失败时 profile 原样不动，旧 nix 仍可用
	sudo -H "$NIXBIN" "${opts[@]}" profile install \
		--profile "$PROFILE" --priority 4 "nixpkgs#nixVersions.latest"

	"$NIXBIN" --version || die "安装后 nix 不可用；回滚：sudo nix profile rollback --profile $PROFILE"
	if jq -e '.elements | has("nix")' "$MANIFEST" >/dev/null; then
		sudo -H "$NIXBIN" profile remove --profile "$PROFILE" nix
	fi
fi

echo "==> 重启 nix-daemon"
sudo launchctl kickstart -k system/org.nixos.nix-daemon

client="$("$NIXBIN" --version)"
# nix store info 的输出走 stderr，必须合并后再提取
daemon="$("$NIXBIN" store info --store daemon 2>&1 | awk '/^Version:/ {print $2}')"

[[ -n "$daemon" ]] || die "读不到 daemon 版本"
echo "client: $client"
echo "daemon: $daemon"
[[ "$client" == *"$daemon"* ]] || die "client/daemon 版本不一致，检查 org.nixos.nix-daemon 是否起来"

echo "==> 完成"
