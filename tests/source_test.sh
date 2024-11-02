#!/usr/bin/env bash

source ${WORKSPACE_ROOT}/src/target.sh
trap - EXIT

test_global_variables() {
    assertEquals "${TARGETS_DIR}" "."
}

source ${SHUNIT2}