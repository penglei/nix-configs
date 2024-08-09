#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$SCRIPT_DIR/../secrets"

datafile="recovery.enc"

workdir=local-build2
mkdir -p "$workdir"

echo "Enter pin to show superkey:"
passage superkey #我使用唯一的超级key进行加密，密码过于复杂，每次显示出来加强记忆

#restore from encrypted file
if [[ -f "$datafile" ]]; then
  pushd "$workdir" >/dev/null
  age -d ../recovery.enc >x.tgz
  tar -zxf x.tgz #extract recovery directory
  rm x.tgz
  popd >/dev/null
else
  mkdir -p "$workdir/recovery"
fi

#do some change

#1. backup passage store
if [[ -d "$HOME/.passage" ]]; then
  pushd "$workdir" >/dev/null
  rm -rf recovery/passage
  cp -R ~/.passage recovery/passage
  popd >/dev/null
fi

echo "You can edit information now"
pushd "$workdir/recovery" >/dev/null
"$SHELL"
popd >/dev/null

#encrypt all
pushd "$workdir" >/dev/null
tar cz ./recovery | age -p >recovery.enc
mv recovery.enc ..
popd >/dev/null

rm -rf "$workdir"
