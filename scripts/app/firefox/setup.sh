#!/bin/bash

print_info "Installing firefox app..."

install_if_dne software-properties-common
sudo add-apt-repository ppa:mozillateam/ppa

echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 900
' | sudo tee /etc/apt/preferences.d/mozilla

install_if_dne firefox
