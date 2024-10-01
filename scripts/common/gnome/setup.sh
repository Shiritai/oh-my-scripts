#!/bin/bash

install_if_dne ubuntu-desktop \
               fcitx-config-gtk \
               gnome-usage

sudo apt-get purge -y --autoremove gnome-initial-setup
