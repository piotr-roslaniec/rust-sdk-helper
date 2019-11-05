#!/bin/bash

IMAGE=rust-sdk
SRC=$(pwd)
DIR=$(basename $SRC)
CONTAINER=$IMAGE-$DIR

usage() {
    cat <<EOF
usage: $0 options

Set up Docker container with baidu/rust-sgx-sdk.

OPTIONS:
   -h, --help    Show this message
   -r, --run     Create/recreate container and attach
   -a, --attach  Attach shell to existing container
   -k, --kill    Kill container if exists
EOF
}

run() {
    ls /dev/isgx >/dev/null &>/dev/null || {
        echo "SGX Driver NOT installed"
        exit 1
    }

    if [[ $(docker ps --all --filter "name=^/$CONTAINER$" --format '{{.Names}}') == $CONTAINER ]]; then
        docker start $CONTAINER
        docker attach $CONTAINER
    else
        docker run -d -it -v $SRC:/root/$DIR:rw --device /dev/isgx \
            -e SGX_MODE=HW \
            -e IAS_API_KEY=$IAS_API_KEY \
            -e IAS_SPID=$IAS_SPID \
            --name $CONTAINER $IMAGE
    fi
}

attach() {
    docker exec -it $CONTAINER bash
}

kill() {
    docker rm -f $CONTAINER &>/dev/null && echo 'Removed old container'
}

while test $# -gt 0; do
    case "$1" in
    -h | --help)
        usage
        exit 1
        ;;
    -r | --run)
        shift
        run
        exit 0
        ;;
    -a | --attach)
        shift
        attach
        exit 0
        ;;
    -k | --kill)
        shift
        kill
        exit 0
        ;;
    ?)
        usage
        exit 1
        ;;
    esac
done
