#!/usr/bin/env bash
set -e
cd $(dirname ${0})

: ${RUN_TARGET:?RUN_TARGET=example1|example2 bash ${0}}

source ../../src/btarget.sh

if [ "${1}" == "??" ]; then
    trap - EXIT
    shift
    "${@}"
fi
