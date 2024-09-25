#!/bin/bash

check_and_install() {
    if ! command -v $1 > /dev/null
    then
        print_info "$1 DNE, installing them..."
        $INSTALL_CMD -y $1
    fi
}
