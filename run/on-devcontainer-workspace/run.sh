#!/usr/bin/env bash
set -e
cd $(dirname "${0}")

source ../supports/bask/src/bask.sh

bask_default_task="usage"

task_usage() {
    bask_list_tasks
}

task_test() {
    cd ../..
    bats --show-output-of-passing-tests --print-output-on-failure ./tests
}
