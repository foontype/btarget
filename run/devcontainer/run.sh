#!/usr/bin/env bash
set -e
cd $(dirname "${0}")

source ../../examples/bask-target-example/supports/bask/src/bask.sh

bask_default_task="usage"

task_usage() {
    bask_list_tasks
}
