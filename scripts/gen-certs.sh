#!/bin/bash

set -x

SCRIPTPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOTDIR=$(dirname "${SCRIPTPATH}")

WORK_DIR=${ROOTDIR}/certs

mkdir -p $WORK_DIR

cd $WORK_DIR

config_file=config.json
cat <<EOF >$config_file
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "ca": {
        "usages": [
          "signing",
          "key encipherment"
        ],
        "expiry": "87600h"
      },
      "server": {
        "usages": [
          "signing",
          "key encipherment",
          "server auth"
        ],
        "expiry": "87600h"
      },
      "client": {
        "usages": [
          "signing",
          "key encipherment",
          "client auth"
        ],
        "expiry": "87600h"
      }
    }
  }
}
EOF

# #create ca
# cfssl gencert -initca - <<EOF | cfssljson -bare ca
# {
#   "CN": "fixpoint:ca",
#   "key": {
#     "algo": "rsa",
#     "size": 2048
#   }
# }
# EOF

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem --config=config.json -profile=server - <<EOF | cfssljson -bare resolver
{
  "CN": "fixpoint:resolver",
  "hosts": [
    "resolve.lnote365.com",
    "43.156.152.201",
    "127.0.0.1",
    "localhost"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  }
}
EOF

# install certs
rm -rf $config_file *.csr
