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
    local run_targets=($(_btarget_list_run_targets_sorted))

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
        _btarget_error "${error}"
    fi

    exit 1
}

_btarget_error() {
    local error="${1}"
    echo "Error: ${error}"
    exit 1
}

_btarget_list_run_target_dirs() {
    for s in ${RUN_TARGET_NEXT_SHELLS}; do
        for t in $(compgen -G "${RUN_TARGET_SEARCH_DIR}/${sub_dir}/*/${s}"); do
            echo "$(basename $(dirname ${t}))"
        done
    done
}

_btarget_list_run_target_dirs_only_available() {
    local env=$(_btarget_current_env)
    local run_targets=$(_btarget_list_run_target_dirs)

    if [ -z "${env}" ]; then
        local prefixed_env=$(_btarget_prefixed_env)
        for t in ${run_targets}; do
            if [ ! "${t}" = "${prefixed_env}"* ]; then
                echo "${t}"
            fi
        done
    else
        local prefixed_env=$(_btarget_prefixed_env "${env}")
        for t in ${run_targets}; do
            if [ "${t}" = "${prefixed_env}" ]; then
                echo "${t}"
            fi
        done
    fi
}

_btarget_list_run_targets_sorted() {
    _btarget_list_run_target_dirs_only_available | sort
}

_btarget_select_run_targets() {
    local input=$(echo "${1}" | grep '^[a-z-][a-z0-9-]*$')

    if [ -z "${input}" ]; then
        return
    fi

    local pattern=$(_btarget_make_select_pattern "${input}")
    for t in $(_btarget_list_run_targets_sorted); do
        if [[ "$(basename "${t}")" == ${pattern} ]]; then
            echo "${t}"
        fi
    done
}

_btarget_run_target_next_shell() {
    local next_shell="${1}"

    shift

    if [ -z "${next_shell}" ]; then
        _btarget_error "no next shell"
    fi

    bash ${next_shell} "${@}"
}

_btarget_run_target_dir() {
    local run_target_dir="${1}"

    shift

    cd "${run_target_dir}"
    echo "(in $(pwd))"

    local next_shell=$(_btarget_get_next_shell)
    _btarget_run_target_next_shell "${next_shell}" "${@}"
}

_btarget_run_target() {
    local input="${1}"

    # TODO
    # NOTE: auto-select by env, or consume first selector.
    local env=$(_btarget_current_env)
    if [ -n "${env}" -a -z "${RUN_TARGET_SEARCH_SHELL}" ]; then
        local prefixed_env=$(_btarget_prefixed_env "${env}")
        input="${prefixed_env}"
    elif [ ${#} -gt 0 ]; then
        shift
    fi

    if [ "${input}" = "" ]; then
        _btarget_usage "please specify run target."
    fi

    local run_targets=($(_btarget_select_run_targets "${input}"))
    if [ "${#run_targets[@]}" -eq 0 ]; then
        _btarget_usage "unmatched run target."
    fi
    if [ "${#run_targets[@]}" -gt 1 ]; then
        _btarget_usage "multiple run targets: ${run_targets[*]}"
    fi

    _btarget_run_target_dir ${run_targets[0]} "${@}"
}

_btarget_make_select_pattern() {
    echo "${1}*" | sed 's/-/*-/g'
}

_btarget_current_env() {
    local env=$(echo "${RUN_TARGET_ENV}" | grep '^[a-z-][a-z0-9-]*$')

    if [ ! "${env}" = "${RUN_TARGET_ENV}" ]; then
        echo "${RUN_TARGET_ENV_INVALID}"
        return
    fi

    echo "${env}"
}

_btarget_prefixed_env() {
    local env="${1:-}"

    echo "${RUN_TARGET_ENV_PREFIX}${env}"
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
    _btarget_run_target "${@}"
}
