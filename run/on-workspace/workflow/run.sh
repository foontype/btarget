#!/usr/bin/env bash
set -e
cd $(dirname "${0}")

source ../../supports/bask/src/bask.sh

bask_default_task="usage"

task_usage() {
    bask_list_tasks
}

task_test() {
    cd ../../..
    bats --print-output-on-failure --pretty --recursive ./tests
}

task_tap() {
    cd ../../..
    bats --tap ./tests
}