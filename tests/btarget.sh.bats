#!/usr/bin/env bats

setup() {
    local original_trap=$(trap -p EXIT)
    source ${WORKSPACE_ROOT}/src/btarget.sh
    eval "${original_trap}"
}

@test "RUN_TARGETS_DIR" {
    [ "${RUN_TARGETS_DIR}" = "." ]
}

@test "_btarget_max_len" {
    local strings=("a" "bc" "def" "g" "hi" "jk")
    local result=$(_btarget_max_len "${strings[@]}")

    [ "$result" = "3" ]
}

@test "_btarget_list_run_targets" {
    compgen() {
        case "${2}" in
        */target.sh) echo "path/to/def/target.sh path/to/bcd/target.sh";;
        */run.sh) echo "path/to/cde/run.sh path/to/abc/run.sh";;
        esac
    }

    run _btarget_list_run_targets

    [ "${output}" = "def
bcd
cde
abc" ]
}

@test "_btarget_list_run_targets_with_env" {
    _btarget_list_run_targets() {
        echo "${1}"
    }

    RUN_TARGET_ENV="x"

    run _btarget_list_run_targets_with_env

    [ "${output}" = "on-x" ]
}

@test "_btarget_list_run_targets_with_env_restrict" {
    _btarget_list_run_targets() {
        echo "t"
    }

    RUN_TARGET_ENV="x"
    RUN_TARGET_ENV_EXPECTED_TO="x"

    run _btarget_list_run_targets_with_env

    [ "${output}" = "t" ]
}

@test "_btarget_list_run_targets_with_env_restrict_empty" {
    _btarget_list_run_targets() {
        echo "t"
    }

    RUN_TARGET_ENV="x"
    RUN_TARGET_ENV_EXPECTED_TO="y"

    run _btarget_list_run_targets_with_env

    [ "${output}" = "" ]
}

@test "_btarget_list_run_targets_with_env_by_sort" {
    _btarget_list_run_targets() {
        echo "bcd
cde
abc
def
fgh
efg"
    }

    run _btarget_list_run_targets_with_env_by_sort

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

    _btarget_list_run_targets() {
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
