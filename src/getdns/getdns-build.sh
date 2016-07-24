#!/usr/bin/env bash

set -e
set -u
set -o pipefail
set -x

VERSION_TEST_SCRIPT="$1"
shift

if [[ -z "$VERSION_TEST_SCRIPT" || ! -x "$VERSION_TEST_SCRIPT" ]];
then
    echo "No outside test script specified: ${VERSION_TEST_SCRIPT}" >&2
    exit 1
fi

VERSION_TEST_SCRIPT_FLAGS="false"

if [[ $(($# > 0)) && "${1:-}" == "--" ]];
then
    VERSION_TEST_SCRIPT_FLAGS="true"
    shift
fi

brew install libtool openssl

export LDFLAGS='-L/usr/local/opt/openssl/lib'
export CPPFLAGS='-I/usr/local/opt/openssl/include'

GETDNS_TARGETS=("v0.9.0" "v1.0.0b1" "v1.0.0b2" "v1.1.0a1")

for GETDNS_TARGET in ${GETDNS_TARGETS[@]};
do
(
    echo "Building getdns ${GETDNS_TARGET}"

    git checkout --force $GETDNS_TARGET
    git clean -fdx
    git submodule update --init

    glibtoolize -ci
    autoreconf -fi

    # Install on the system-level to avoid problems with building libraries depending on getdns.
    ./configure --with-libevent
    #./configure --with-libevent --prefix=$HOME/getdnsosx/export
    #./configure --with-libevent --prefix=$HOME/dev/clients/getdns/upstream/getdns-build/$(git describe)

    make
    make getdns_query
    make install

    export GETDNS_TARGET

    if [[ "$VERSION_TEST_SCRIPT_FLAGS" == "true" ]];
    then
        "$VERSION_TEST_SCRIPT" "$@"
    else
        "$VERSION_TEST_SCRIPT"
    fi
)
done;
