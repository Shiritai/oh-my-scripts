#!/bin/bash

# Install packages if not installed
install_if_dne() {
    _UPDATED=no
    for item in "$@"; do
        if ! command -v $item > /dev/null
        then
            if [ $_UPDATED = "no" ]; then
                print_info "Update package index..."
                sudo apt-get update -qq -y
                _UPDATED=yes
            fi
            print_info "$item DNE, install it..."
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq -y $item > /dev/null
            print_info "$item installed successfully"
        fi
    done
    if [ $_UPDATED = "yes" ]; then
        # clean package list
        print_info "Clean up package and pkg list"
        sudo apt-get clean
        sudo rm -rf /var/lib/apt/lists/*
    fi
}