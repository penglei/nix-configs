#!/usr/bin/env bash

set -euo pipefail

#if we update identities, we should encrypt all again

cd ~/.passage

tmp_prefix=_tmp
passage demo/foo

while read -r -d "" passfile; do
	name="${passfile#./}"
	name="${name%.age}"
	name="${name#store/}"

	echo "$name"

	passage cp -f "$name" "$tmp_prefix/$name"
	passage mv -f "$tmp_prefix/$name" "$name"

done < <(find . -path '*/.git' -prune -o -path './store/tmp_prefix' -prune -o -iname '*.age' -print0)
