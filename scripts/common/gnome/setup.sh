#!/bin/bash

# only install gnome dependency if using it
if ! [ $USE_GUI = "yes" ]; then
    print_info "gnome (GUI) is not needed"
    exit 0
fi

print_info "Installing Gnome GUI"

install_if_dne gnome-session \
               gnome-terminal \
               gnome-control-center \
               nautilus

remove_if_exist gnome-initial-setup
gsettings set org.gnome.desktop.screensaver lock-enabled false
