#!/bin/bash

start_all_plugins_in() {
    for sub_dir in $(ls -d $1/*/); do
        ${sub_dir%%/}/start.sh >> /dev/null 2>&1 &
    done
}
