#!/bin/bash

print_info "Setup locale to ${LOCALE} and timezone to ${TZ}"

install_if_dne locales

echo "$LOCALE UTF-8" | sudo tee -a /etc/locale.gen
sudo locale-gen

sudo ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime
echo ${TZ} | sudo tee /etc/timezone