#!/bin/bash

install_all_plugins_in() {
    for sub_dir in $(ls -d $1/*/); do
        ${sub_dir%%/}/setup.sh;
    done
}

SCRIPT_DIR=$(realpath $(dirname $0))

# run setup script in common directory
install_all_plugins_in $SCRIPT_DIR/common

# run setup script in custom directory
install_all_plugins_in $SCRIPT_DIR/custom
