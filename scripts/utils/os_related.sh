#!/bin/bash

PKG_MGR=""
PKG_UPDATE=""
PKG_INSTALL=""
PKG_REMOVE=""
PKG_CLEAN=""
PKG_CHECK_INSTALLED=""

set_pkg_mgr() {
    # Supported package manager related literals
    local SUP_PKG_MGR=( apt-get pacman )
    local SUP_PKG_UPDATE=( "apt-get update -qq -y" "pacman -Syu --noconfirm" )
    local SUP_PKG_INSTALL=( "apt-get install -qq -y" "pacman -S --noconfirm" )
    local SUP_PKG_REMOVE=( "apt-get purge -qq -y --autoremove" "pacman -R --noconfirm" )
    local SUP_PKG_CLEAN=( "apt-get clean" "pacman -Sc" )
    local SUP_PKG_CHECK_INSTALLED=( "apt -qq list --installed" "pacman -Qi" )

    for i in "${!SUP_PKG_MGR[@]}"; do
        if ! [[ -z $(command -v ${SUP_PKG_MGR[$i]}) ]]; then
            PKG_MGR=${SUP_PKG_MGR[$i]}
            PKG_UPDATE=${SUP_PKG_UPDATE[$i]}
            PKG_INSTALL=${SUP_PKG_INSTALL[$i]}
            PKG_REMOVE=${SUP_PKG_REMOVE[$i]}
            PKG_CLEAN=${SUP_PKG_CLEAN[$i]}
            PKG_CHECK_INSTALLED=${SUP_PKG_CHECK_INSTALLED[$i]}
        fi
    done

    print_info "Package manager $PKG_MGR detected"
}

# Initialize references of os-related package manager
# e.g. `PKG_MGR`, `PKG_UPDATE`, `PKG_INSTALL`, ...
use_pkg_mgr() {
    if [[ -z $PKG_MGR ]]; then
        set_pkg_mgr
    fi
}
