#!/usr/bin/env bats

setup() {
    source() {
        [ "$(basename "${1}")" = "bask.sh" ] && return
        command source "${@}"
    }

    source "./run/shell-tester/run.sh"
}

@test "_os_path" {
    cygpath() {
        echo "${1},${2}"
    }

    export OSTYPE=cygwin
    run _os_path /test/path

    [ "${output}" = "-w,/test/path" ]
}
