#!/usr/bin/env bash

source ${WORKSPACE_ROOT}/src/target.sh
trap - EXIT

test_max_len() {
    local strings=("a" "bc" "def" "g" "hi" "jk")
    local result=$(_max_len "${strings[@]}")
    assertEquals "${result}" "3"
}

source ${SHUNIT2}