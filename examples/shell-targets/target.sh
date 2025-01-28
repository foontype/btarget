#!/usr/bin/env bash
set -e
cd $(dirname ${0})

RUN_TARGET_SEARCH_DIR="workflows"
RUN_TARGET_SEARCH_SHELL="*"

source ../../src/btarget.sh

if [ "${1}" == "??" ]; then
    trap - EXIT
    shift
    "${@}"
fi
