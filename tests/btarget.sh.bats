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

@test "_btarget_current_env" {
    RUN_TARGET_ENV="x"

    run _btarget_current_env

    [ "${output}" = "x" ]
}

@test "_btarget_current_env_invalid" {
    RUN_TARGET_ENV="InVaLiDEnV"

    run _btarget_current_env

    [ "${output}" = "unknown" ]
}

@test "_btarget_current_env_invalid_configured" {
    RUN_TARGET_ENV="InVaLiDEnV"
    RUN_TARGET_ENV_INVALID="expected_invalid_env"

    run _btarget_current_env

    [ "${output}" = "expected_invalid_env" ]
}

@test "_btarget_list_run_targets" {
    compgen() {
        case "${2}" in
        */target.sh) echo "path/to/def/target.sh path/to/bcd/target.sh";;
        */run.sh) echo "path/to/cde/run.sh path/to/abc/run.sh";;
        */task.sh) echo "path/to/ghi/run.sh path/to/hij/run.sh";;
        */workflow.sh) echo "path/to/ijk/run.sh path/to/jkl/run.sh";;
        esac
    }

    run _btarget_list_run_targets

    [ "${output}" = "def
bcd
cde
abc
ghi
hij
ijk
jkl" ]
}


@test "_btarget_list_run_target_dirs_only_available" {
    _btarget_list_run_target_dirs() {
        echo "on-x
on-y
z"
    }

    RUN_TARGET_ENV="x"

    run _btarget_list_run_target_dirs_only_available

    [ "${output}" = "on-x" ]
}

@test "_btarget_list_run_targets_for_shells" {
    _btarget_list_run_target_shells() {
        echo "a
b
c"
    }

    RUN_TARGET_SEARCH_SHELLS="*"

    run _btarget_list_run_targets

    [ "${output}" = "a
b
c" ]
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
