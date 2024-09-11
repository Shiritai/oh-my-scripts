#!/bin/bash

print_info() {
    echo -e "[\e[1;34mINFO\e[0m] $1"
}

check_and_install() {
    if ! command -v $1 > /dev/null
    then
        print_info "$1 DNE, installing them..."
        $INSTALL_CMD -y $1
    fi
}
