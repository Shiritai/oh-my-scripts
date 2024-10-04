#!/bin/bash

# only install ssh dependency if using it
if ! [ $USE_SSH = "yes" ]; then
    print_info "SSH service is not needed"
    exit 0
fi

install_if_dne openssh-server

sudo sed -i "s/#Port.*/Port 22/" /etc/ssh/sshd_config
sudo sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/" /etc/ssh/sshd_config
sudo sed -i "s/#PasswordAuthentication.*/PasswordAuthentication yes/" /etc/ssh/sshd_config

if [ ${USE_SYSTEMD} = yes ]; then
    sudo systemctl enable ssh
fi
