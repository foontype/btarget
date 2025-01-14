#!/usr/bin/env bash

trap '[[ ${?} -eq 0 ]] && _btarget_bootstrap "${@}"' EXIT

RUN_TARGETS_DIR=${RUN_TARGETS_DIR:-.}
RUN_TARGET_SHELL=${RUN_TARGET_SHELL:-target.sh}
RUN_TARGET_RUN_SHELL=${RUN_TARGET_RUN_SHELL:-run.sh}
RUN_TARGET_DESC_FILENAME=${RUN_TARGET_DESC_FILENAME:-RUN_TARGET_DESC}
RUN_TARGET_ENV=${RUN_TARGET_ENV:-}
RUN_TARGET_ENV_PREFIX=${RUN_TARGET_ENV_PREFIX:-on-}

_btarget_usage() {
    local error="${1}"
    local example_target="run-target"
    local run_targets=($(_btarget_list_run_targets_with_env))

    if [ "${#run_targets[@]}" -gt 0 ]; then
        local max_length=$(_btarget_max_len "${run_targets[@]}")

        echo ""
        echo "Available run targets:"
        for t in ${run_targets[*]}; do
            local desc=$(_btarget_get_desc "${t}")
            [ -z "${desc}" ] \
                && echo " * $(basename "${t}")" \
                || printf " * %-${max_length}s   # %s\n" "${t}" "${desc}"
            example_target="${t}"
        done

        echo ""
        echo "Usage:"
        echo "  ${0} <run target>"
        echo ""
        echo "  ex) ${0} ${example_target}"

        echo ""
        echo "  run target can be abbreviated at each slash."
        echo "  for instance, \"th-i-ap\" matches \"this-is-apple\"."
        echo ""
    else
        error="no run targets found."
    fi

    if [ -n "${error}" ]; then
        echo "Error: ${error}"
    fi

    exit 1
}

_btarget_list_run_targets() {
    local filter="${1:-}${1:+/}"

    for t in $(compgen -G "${RUN_TARGETS_DIR}/${filter}*/${RUN_TARGET_SHELL}"); do
        echo "${filter}$(basename $(dirname ${t}))"
    done
    for t in $(compgen -G "${RUN_TARGETS_DIR}/${filter}*/${RUN_TARGET_RUN_SHELL}"); do
        echo "${filter}$(basename $(dirname ${t}))"
    done
}

_btarget_list_run_targets_with_env() {
    local env=$(echo "${RUN_TARGET_ENV}" | grep '^[a-z-][a-z-]*$')

    if [ "${env}" = "" ]; then
        _btarget_list_run_targets
    else
        _btarget_list_run_targets "${RUN_TARGET_ENV_PREFIX}${env}"
    fi
}

_btarget_list_run_targets_with_env_by_sort() {
    _btarget_list_run_targets_with_env | sort
}

_btarget_select_run_targets() {
    local input=$(echo "${1}" | grep '^[a-z-][a-z-]*$')
    if [ -z "${input}" ]; then
        return
    fi

    local pattern=$(_btarget_make_select_pattern "${input}")
    for t in $(_btarget_list_run_targets_with_env_by_sort); do
        if [[ "$(basename "${t}")" == ${pattern} ]]; then
            echo "${t}"
        fi
    done
}

_btarget_make_select_pattern() {
    echo "${1}*" | sed 's/-/*-/g'
}

_btarget_run_target() {
    local run_target="${1}"
    local run_target_dir="${RUN_TARGETS_DIR}/${run_target}"
    local run_target_shell="./${RUN_TARGET_SHELL}"
    local run_target_run_shell="./${RUN_TARGET_RUN_SHELL}"

    shift

    cd "${run_target_dir}"
    echo "(in $(pwd))"

    if [ ! -f "${run_target_shell}" ]; then
        run_target_shell="${run_target_run_shell}"
    fi

    ${run_target_shell} "${@}"
}

_btarget_get_desc() {
    local run_target="${1}"
    local desc_path="./${run_target}/${RUN_TARGET_DESC_FILENAME}"

    if [ -f "${desc_path}" ]; then
        cat "${desc_path}" | head -n 1
    fi
}

_btarget_max_len() {
    local arr=("${@}")
    local max_length=0

    for item in "${arr[@]}"; do
        length=${#item}
        if (( length > max_length )); then
            max_length=$length
        fi
    done

    echo "${max_length}"
}

_btarget_bootstrap() {
    local input="${1}"

    case "${input}" in
    "")
        _btarget_usage "please specify run target."
        ;;
    *)
        local run_targets=($(_btarget_select_run_targets "${input}"))
        if [ "${#run_targets[@]}" -eq 0 ]; then
            _btarget_usage "unmatched run target."
        fi
        if [ "${#run_targets[@]}" -gt 1 ]; then
            _btarget_usage "multiple run targets: ${run_targets[*]}"
        fi

        shift
        _btarget_run_target ${run_targets[0]} "${@}"
        ;;
    esac
}
