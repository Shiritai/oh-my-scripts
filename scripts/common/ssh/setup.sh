#!/bin/bash

install_if_dne openssh-server

sudo sed -i "s/#Port.*/Port 22/" /etc/ssh/sshd_config
sudo sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/" /etc/ssh/sshd_config
sudo sed -i "s/#PasswordAuthentication.*/PasswordAuthentication yes/" /etc/ssh/sshd_config

sudo /etc/init.d/ssh start
