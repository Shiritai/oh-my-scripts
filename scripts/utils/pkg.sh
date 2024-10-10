#!/bin/bash

# Install packages if not installed
install_if_dne() {
    use_pkg_mgr
    
    local _UPDATED=no
    for item in "$@"; do
        if [[ -z $(sudo $PKG_CHECK_INSTALLED $item 2>/dev/null) ]]
        then
            if [ $_UPDATED = "no" ]; then
                print_info "Update package index..."
                sudo $PKG_UPDATE
                _UPDATED=yes
            fi
            print_info "$item DNE, install it..."
            sudo $PKG_INSTALL $item > /dev/null
            print_info "$item installed successfully"
        else
            print_info "$item exists, skip installation"
        fi
    done
    if [ $_UPDATED = "yes" ]; then
        # clean package list
        print_info "Clean up package and pkg list"
        sudo $PKG_CLEAN
    fi
}

remove_if_exist() {
    use_pkg_mgr
    
    for item in "$@"; do
        if ! [[ -z $(sudo $PKG_CHECK_INSTALLED 2>/dev/null) ]]
        then
            print_info "$item exist, uninstall it..."
            sudo $PKG_REMOVE $item > /dev/null
            print_info "$item uninstalled successfully"
        else
            print_info "$item DNE, skip uninstallation"
        fi
    done
}
