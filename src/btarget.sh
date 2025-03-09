#!/usr/bin/env bash

trap '[[ ${?} -eq 0 ]] && _btarget_bootstrap "${@}"' EXIT

RUN_TARGET_SEARCH_DIR=${RUN_TARGET_SEARCH_DIR:-.}
RUN_TARGET_NEXT_SHELL=${RUN_TARGET_NEXT_SHELL:-task.sh}
RUN_TARGET_NEXT_SHELL_EXT=${RUN_TARGET_NEXT_SHELL_EXT:-.sh}
RUN_TARGET_DESC_FILENAME=${RUN_TARGET_DESC_FILENAME:-RUN_TARGET_DESC}
RUN_TARGET_ENV=${RUN_TARGET_ENV:-}

declare -gA _btarget_colors=(
    [black]="$(echo -e '\e[30m')"
    [red]="$(echo -e '\e[31m')"
    [cyan]="$(echo -e '\e[36m')"
    [gray]="$(echo -e '\e[90m')"
    [white]="$(echo -e '\e[97m')"
    [reset]="$(echo -e '\e[0m')"
)

_btarget_log() {
    echo "${_btarget_colors[gray]}${_btarget_colors[reset]}${*}"
}

_btarget_log_error() {
    _btarget_log "${_btarget_colors[red]}${*}${_btarget_colors[reset]}"
}

_btarget_log_info() {
    _btarget_log "${_btarget_colors[cyan]}${*}${_btarget_colors[reset]}"
}

_btarget_log_debug() {
    _btarget_log "${_btarget_colors[gray]}${*}${_btarget_colors[reset]}"
}

_btarget_done() {
    local message="${1}"
    _btarget_log_debug "${message}"
    exit 0
}

_btarget_error() {
    local error="${1}"
    _btarget_log_error "error: ${error}"
    exit 1
}


_btarget_usage() {
    local error="${1}"
    local run_targets=($(_btarget_list_run_targets_sorted))

    if [ "${#run_targets[@]}" -gt 0 ]; then
        local max_length=$(_btarget_max_len "${run_targets[@]}")
        local example_target="${run_targets[0]}"

        _btarget_log ""
        _btarget_log "usage:"
        _btarget_log "  ${0} <run target>"
        _btarget_log ""
        _btarget_log "  ex) ${0} ${example_target}"

        _btarget_log ""
        _btarget_log "  run target can be abbreviated at each dash."
        _btarget_log "  for instance, \"th-i-ap\" matches \"this-is-apple\"."

        _btarget_log ""
        _btarget_log "available run targets:"
        for t in ${run_targets[*]}; do
            local desc=$(_btarget_get_desc "${t}")
            [ -z "${desc}" ] \
                && _btarget_log_info "  $(basename "${t}")" \
                || printf "  %-${max_length}s   # %s\n" "${t}" "${desc}"
        done
        _btarget_log ""
    else
        error="no run targets found."
    fi

    if [ -n "${error}" ]; then
        _btarget_error "${error}"
    fi

    exit 1
}

_btarget_list_run_target_dirs() {
    for s in $(_btarget_next_shells); do
        for t in $(compgen -G "${RUN_TARGET_SEARCH_DIR}/*/${s}"); do
            echo "$(basename $(dirname ${t}))"
        done
    done
}

_btarget_list_run_targets_sorted() {
    _btarget_list_run_target_dirs | sort
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
    local run_target_name="${2}"

    shift 2

    if [ -z "${next_shell}" ]; then
        _btarget_error "no next shell"
    fi

    bash ${next_shell} "${@}"
}

_btarget_run_target_dir() {
    local run_target_dir="${1}"
    local run_target_name="${2}"

    shift 2

    cd "${run_target_dir}"
    _btarget_log_debug "in $(pwd)"

    local next_shell=$(_btarget_get_next_shell)
    _btarget_run_target_next_shell "${next_shell}" "${run_target_name}" "${@}"
}

_btarget_run_target() {
    local input="${1}"
    local auto_input=""

    # auto select when run target is specified
    if [ -n "${RUN_TARGET}" ]; then
        local auto_targets=($(_btarget_list_run_targets_sorted))
        if [ "${#auto_targets[@]}" -eq 1 ]; then
            auto_input="${auto_targets[0]}"
        fi
    fi

    if [ -n "${auto_input}" ]; then
        input="${auto_input}"
    elif [ ${#} -gt 0 ]; then
        shift
    fi

    if [ -z "${input}" ]; then
        _btarget_usage "please specify run target."
    fi

    local run_targets=($(_btarget_select_run_targets "${input}"))
    if [ "${#run_targets[@]}" -eq 0 ]; then
        _btarget_usage "unmatched run target."
    fi
    if [ "${#run_targets[@]}" -gt 1 ]; then
        _btarget_usage "multiple run targets: ${run_targets[*]}"
    fi

    local run_target_name=$(basename "${run_targets[0]}")
    _btarget_run_target_dir "${run_targets[0]}" "${run_target_name}" "${@}"

    if [ ${?} -eq 0 ]; then
        _btarget_done "run target '${run_target_name}' finished (${?})"
    else 
        _btarget_error "run target '${run_target_name}' failed (${?})"
    fi
}

_btarget_make_select_pattern() {
    echo "${1}*" | sed 's/-/*-/g'
}

_btarget_next_shells() {
    if [ -z "${RUN_TARGET}" ]; then
        echo "${RUN_TARGET_NEXT_SHELL}"
        return
    fi

    local shell_name=$(basename "${RUN_TARGET_NEXT_SHELL}" "${RUN_TARGET_NEXT_SHELL_EXT}")
    for t in ${RUN_TARGET}; do
        echo "${shell_name}.${t}${RUN_TARGET_NEXT_SHELL_EXT}"
    done
}

_btarget_get_next_shell() {
    for s in $(_btarget_next_shells); do
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
    if [ -n "${RUN_TARGET_ENV}" ]; then
        _btarget_log_debug "RUN_TARGET_ENV='${RUN_TARGET_ENV}'"
    fi

    _btarget_run_target "${@}"
}
