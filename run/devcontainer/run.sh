#!/usr/bin/env bash
set -e
cd $(dirname "${0}")

source ../supports/bask/src/bask.sh

bask_default_task="usage"

task_usage() {
    bask_list_tasks
}

task_down() {
    docker compose down
}

task_test() {
    docker compose exec workspace ./run/on-workspace/run.sh test
}
