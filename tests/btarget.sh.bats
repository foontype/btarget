#!/usr/bin/env bats

setup() {
    local original_trap=$(trap -p EXIT)
    source ./src/btarget.sh
    eval "${original_trap}"
}

@test "RUN_TARGET_SEARCH_DIR" {
    [ "${RUN_TARGET_SEARCH_DIR}" = "." ]
}

@test "_btarget_max_len" {
    local strings=("a" "bc" "def" "g" "hi" "jk")
    local result=$(_btarget_max_len "${strings[@]}")

    [ "$result" = "3" ]
}

@test "_btarget_list_run_target_dirs" {
    compgen() {
        case "${2}" in
        */task.sh) echo "path/to/ghi/task.sh path/to/hij/task.sh";;
        esac
    }

    run _btarget_list_run_target_dirs

    [ "${output}" = "ghi
hij" ]
}

@test "_btarget_list_run_targets_sorted" {
    _btarget_list_run_target_dirs() {
        echo "bcd
cde
abc
def
fgh
efg"
    }

    run _btarget_list_run_targets_sorted

    [ "${output}" = "abc
bcd
cde
def
efg
fgh" ]
}

@test "_btarget_make_select_pattern" {
    local expects=(
        '"ab" "ab*"'
        '"ab-cd" "ab*-cd*"'
        '"!ab" "!ab*"'
    )

    for x in "${expects[@]}"; do
        echo "running ... ${x}"
        eval "set ${x}"
        run _btarget_make_select_pattern "${1}"
        [ "${output}" = "${2}" ]
    done
}

@test "_btarget_select_run_targets" {
    local expects=(
        '"a-z" "" no-match.'
        '"a" "abc" match by simple abbreviation.'
        '"b-c-d" "bcd-cde-def" match by slash abbreviation.'
        '"b-c" "bcd-cde
bcd-cde-def" multiple match.'
    )

    _btarget_list_run_target_dirs() {
        echo "abc
bcd-cde
bcd-cde-def"
    }

    for x in "${expects[@]}"; do
        echo "running ... ${x}"
        eval "set ${x}"
        run _btarget_select_run_targets "${1}"
        [ "${output}" = "${2}" ]
    done
}
