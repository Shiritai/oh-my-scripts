#!/bin/bash

# Install packages if not installed
install_if_dne() {
    _UPDATED=no
    for item in "$@"; do
        if [[ -z $(sudo apt -qq list $item --installed 2>/dev/null) ]]
        then
            if [ $_UPDATED = "no" ]; then
                print_info "Update package index..."
                sudo apt-get update -qq -y
                _UPDATED=yes
            fi
            print_info "$item DNE, install it..."
            sudo apt-get install -qq -y $item > /dev/null
            print_info "$item installed successfully"
        else
            print_info "$item exists, skip installation"
        fi
    done
    if [ $_UPDATED = "yes" ]; then
        # clean package list
        print_info "Clean up package and pkg list"
        sudo apt-get clean
        sudo rm -rf /var/lib/apt/lists/*
    fi
}

remove_if_exist() {
    for item in "$@"; do
        if ! [[ -z $(sudo apt -qq list $item --installed 2>/dev/null) ]]
        then
            print_info "$item exist, uninstall it..."
            sudo apt-get purge -qq -y --autoremove $item > /dev/null
            print_info "$item uninstalled successfully"
        else
            print_info "$item DNE, skip uninstallation"
        fi
    done
}
