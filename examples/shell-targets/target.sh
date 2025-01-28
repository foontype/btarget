#!/usr/bin/env bash
set -e
cd $(dirname ${0})

RUN_TARGET_SEARCH_DIR="workflows"
RUN_TARGET_SEARCH_SHELLS="example1.sh example2.sh"

source ../../src/btarget.sh

if [ "${1}" == "??" ]; then
    trap - EXIT
    shift
    "${@}"
fi
