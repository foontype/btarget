#!/usr/bin/env bats

source ${WORKSPACE_ROOT}/src/target.sh
trap - EXIT

@test "TARGETS_DIR" {
    [ "${TARGETS_DIR}" = "." ]
}

@test "_max_len" {
    local strings=("a" "bc" "def" "g" "hi" "jk")
    local result=$(_max_len "${strings[@]}")

    [ "$result" = "3" ]
}
