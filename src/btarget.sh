#!/usr/bin/env bash

trap '[[ ${?} -eq 0 ]] && _btarget_bootstrap "${@}"' EXIT

RUN_TARGET_SEARCH_DIR=${RUN_TARGET_SEARCH_DIR:-.}
RUN_TARGET_NEXT_SHELLS=${RUN_TARGET_NEXT_SHELLS:-target.sh run.sh task.sh workflow.sh}
RUN_TARGET_DESC_FILENAME=${RUN_TARGET_DESC_FILENAME:-RUN_TARGET_DESC}
RUN_TARGET_ENV=${RUN_TARGET_ENV:-}
RUN_TARGET_ENV_PREFIX=${RUN_TARGET_ENV_PREFIX:-on-}
RUN_TARGET_ENV_INVALID=${RUN_TARGET_ENV_INVALID:-unknown}

_btarget_usage() {
    local error="${1}"
    local run_targets=($(_btarget_list_run_targets_with_env))

    if [ "${#run_targets[@]}" -gt 0 ]; then
        local max_length=$(_btarget_max_len "${run_targets[@]}")
        local example_target="${run_targets[0]}"

        echo ""
        echo "usage:"
        echo "  ${0} <run target>"
        echo ""
        echo "  ex) ${0} ${example_target}"

        echo ""
        echo "  run target can be abbreviated at each dash."
        echo "  for instance, \"th-i-ap\" matches \"this-is-apple\"."

        echo ""
        echo "available run targets:"
        for t in ${run_targets[*]}; do
            local desc=$(_btarget_get_desc "${t}")
            [ -z "${desc}" ] \
                && echo "  * $(basename "${t}")" \
                || printf "  * %-${max_length}s   # %s\n" "${t}" "${desc}"
        done
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

    for s in ${RUN_TARGET_NEXT_SHELLS}; do
        for t in $(compgen -G "${RUN_TARGET_SEARCH_DIR}/${filter}*/${s}"); do
            echo "${filter}$(basename $(dirname ${t}))"
        done
    done
}

_btarget_list_run_targets_with_env() {
    local env=$(_btarget_current_env)

    if [ -z "${env}" ]; then
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

_btarget_run_target() {
    local run_target="${1}"
    local run_target_dir="${RUN_TARGET_SEARCH_DIR}/${run_target}"

    shift

    cd "${run_target_dir}"
    echo "(in $(pwd))"

    local next_shell=$(_btarget_get_next_shell)
    if [ -z "${next_shell}" ]; then
        echo "no next shell"
        exit 1
    fi

    # NOTE: once RUN_TARGET_ENV used, no longer needed.
    RUN_TARGET_ENV= ${next_shell} "${@}"
}

_btarget_make_select_pattern() {
    echo "${1}*" | sed 's/-/*-/g'
}

_btarget_current_env() {
    local env=$(echo "${RUN_TARGET_ENV}" | grep '^[a-z-][a-z-]*$')

    if [ ! "${env}" = "${RUN_TARGET_ENV}" ]; then
        echo "${RUN_TARGET_ENV_INVALID}"
        return
    fi

    echo "${env}"
}

_btarget_get_next_shell() {
    for s in ${RUN_TARGET_NEXT_SHELLS}; do
        if [ -f "./${s}" ]; then
            echo "./${s}"
            return
        fi
    done
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
