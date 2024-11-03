#!/usr/bin/env bash
set -e
cd $(dirname "${0}")

source ../../../run/supports/bask/src/bask.sh

bask_default_task="usage"

task_usage() {
    bask_list_tasks
}

task_hello_world() {
    bask_log "hello, world!"
}
