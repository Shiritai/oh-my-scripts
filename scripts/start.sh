#!/bin/bash

start_all_plugins_in() {
    for sub_dir in $(ls -d $1/*/); do
        ${sub_dir%%/}/start.sh >> /dev/null 2>&1 &
    done
}

SCRIPT_DIR=$(realpath $(dirname $0))

# run setup script in common directory
start_all_plugins_in $SCRIPT_DIR/common

# run setup script in custom directory
start_all_plugins_in $SCRIPT_DIR/custom

bash
