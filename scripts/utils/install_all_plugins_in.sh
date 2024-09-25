#!/bin/bash

install_all_plugins_in() {
    for sub_dir in $(ls -d $1/*/); do
        ${sub_dir%%/}/setup.sh;
    done
}
