#!/bin/bash

# only install systemd dependency if using it
if ! [ $USE_SYSTEMD = "yes" ]; then
    print_info "Systemd is not needed"
    exit 0
fi

print_info "Use systemd"

install_if_dne dbus \
               dbus-x11 \
               systemd
