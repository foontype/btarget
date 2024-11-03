#!/usr/bin/env bats

setup() {
    local original_trap=$(trap -p EXIT)
    source ${WORKSPACE_ROOT}/src/target.sh
    eval "${original_trap}"
}

@test "TARGETS_DIR" {
    [ "${TARGETS_DIR}" = "." ]
}

@test "_max_len" {
    local strings=("a" "bc" "def" "g" "hi" "jk")
    local result=$(_max_len "${strings[@]}")

    [ "$result" = "3" ]
}

@test "_list_run_targets" {
    compgen() {
        case "${2}" in
        */target.sh) echo "path/to/def/target.sh path/to/bcd/target.sh";;
        */run.sh) echo "path/to/cde/run.sh path/to/abc/run.sh";;
        esac
    }

    run _list_run_targets

    [ "${output}" = "def
bcd
cde
abc" ]
}

@test "_list_sourted_run_targets" {
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

@test "_make_select_pattern" {
    run _make_select_pattern "ab-cd"
    [ "${output}" = "ab*-cd*" ]
}

@test "_make_select_pattern: no shashes" {
    run _make_select_pattern "ab"
    [ "${output}" = "ab*" ]
}

@test "_make_select_pattern: invalid char becomes empty" {
    run _make_select_pattern "!ab"
    [ "${output}" = "" ]
}
