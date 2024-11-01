#!/usr/bin/env bash

trap '[[ ${?} -eq 0 ]] && _bootstrap "${@}"' EXIT

TARGETS_DIR=${TARGETS_DIR:-.}
TARGET_SHELL=${TARGET_SHELL:-run.sh}

_usage() {
    local error="${1}"
    local example_target="run-target"
    local run_targets=($(_list_run_targets))

    if [ "${#run_targets[@]}" -gt 0 ]; then
        echo ""
        echo "Available run targets:"
        for t in ${run_targets}; do
            echo "  * ${t}"
            example_target="${t}"
        done

        echo ""
        echo "Usage:"
        echo "  ${0} <run target>"

        echo ""
        echo "  ex) ${0} ${example_target}"
        echo ""
    else
        error="no run target found."
    fi

    if [ -n "${error}" ]; then
        echo "Error: ${error}"
    fi

    exit 1
}

_list_run_targets() {
    for t in $(compgen -G ${TARGETS_DIR}/*/${TARGET_SHELL}); do
        echo $(basename $(dirname ${t}))
    done
}

_select_run_targets() {
    local input="${1}"
    local pattern=$(_make_select_pattern "${input}")

    for t in $(_list_run_targets); do
        if [[ "${t}" == ${pattern} ]]; then
            echo "${t}"
        fi
    done
}

_make_select_pattern() {
    echo "${1}*" | sed 's/-/*-/g' | grep '^[a-z\*-][a-z\*-]*$'
}

_run_target() {
    local run_target="${1}"
    local run_target_dir="${TARGETS_DIR}/${run_target}"
    local run_target_shell="./${TARGET_SHELL}"

    shift

    cd "${run_target_dir}"
    echo "(in $(pwd))"
    ${run_target_shell} "${@}"
}

_bootstrap() {
    local input="${1}"

    case "${input}" in
    "")
        _usage "please specify run target."
        ;;
    *)
        local run_targets=($(_select_run_targets "${input}"))
        if [ "${#run_targets[@]}" -eq 0 ]; then
            _usage "unmatched run target."
        fi
        if [ "${#run_targets[@]}" -gt 1 ]; then
            _usage "multiple run targets: ${run_targets[*]}"
        fi

        shift
        _run_target ${run_targets[0]} "${@}"
        ;;
    esac
}