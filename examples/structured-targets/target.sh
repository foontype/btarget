#!/usr/bin/env bash
set -e
cd $(dirname ${0})

source ../../src/btarget.sh

if [ "${1}" == "??" ]; then
    trap - EXIT
    shift
    "${@}"
fi
