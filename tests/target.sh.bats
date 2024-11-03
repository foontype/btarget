#!/usr/bin/env bats

setup() {
    source ${WORKSPACE_ROOT}/src/target.sh
    trap - EXIT
}

@test "TARGETS_DIR" {
    [ "${TARGETS_DIR}" = "." ]
}

@test "_max_len" {
    local strings=("a" "bc" "def" "g" "hi" "jk")
    local result=$(_max_len "${strings[@]}")

    [ "$result" = "3" ]
}

@test "_list_sorted_run_targets" {
    compgen() {
        case "${2}" in
        */target.sh) echo "b/bcd/b c/cde/c a/abc/a ";;
        */run.sh) echo "d/def/d f/fgh/f e/efg/e";;
        esac
    }

    run _list_sorted_run_targets

    [ "${output}" = "abc
bcd
cde
def
efg
fgh" ]
}
