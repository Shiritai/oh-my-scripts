#!/bin/bash

# Install packages if not installed
install_if_dne() {
    _UPDATED=no
    for item in "$@"; do
        if ! command -v $item > /dev/null
        then
            print_info "Update package index..."
            if [ $_UPDATED = "no" ]; then
                sudo apt-get update -qq -y
                _UPDATED=yes
            fi
            print_info "$item DNE, install it..."
            sudo apt-get install -qq -y $item > /dev/null
            print_info "$item installed successfully"
        fi
    done
}