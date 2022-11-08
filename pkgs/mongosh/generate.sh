

# nix shell nixpkgs#node2nix
#
# sh generate.sh
#
# note: disable `enableTelemetry` in ~/.mongodb/mongosh/config


MONGOSH_ROOT="$(
    cd "$(dirname "$0")"
    pwd
)"
pushd $MONGOSH_ROOT 1>/dev/null

rm -rf gen && mkdir -p gen

node2nix \
    --input packages.json \
    --output gen/packages.nix \
    --composition gen/composition.nix \
    --strip-optional-dependencies \
    --nodejs-18

popd 1>/dev/null
