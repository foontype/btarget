#!/usr/bin/env bash
set -e
cd $(dirname "${0}")

source ../supports/bask/src/bask.sh

bask_default_task="usage"

task_usage() {
    bask_list_tasks
}

task_test() {
    cd ../../
    docker run \
        --rm \
        -it \
        -v $(_os_path $(pwd)):/code \
        -w "/code" \
        bats/bats:1.11.1 \
        --print-output-on-failure \
        --pretty \
        --recursive \
        ./run/shell-tester/tests
}

_os_path() {
    if [ "${OSTYPE}" == "cygwin" ]; then
        echo "$(cygpath -w "${1}")"
    else
        echo "${1}"
    fi
}
