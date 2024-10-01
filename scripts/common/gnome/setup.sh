#!/bin/bash

# install_if_dne ubuntu-desktop-minimal
install_if_dne gnome-session \
               gnome-terminal \
               gnome-control-center \
               nautilus

sudo apt-get purge -y --autoremove gnome-initial-setup
