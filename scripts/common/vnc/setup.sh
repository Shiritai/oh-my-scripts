#!/bin/bash

# only install vnc dependency if using vnc
if ! [ $USE_VNC = "yes" ]; then
    print_info "No VNC service needed"
    exit 0
fi

print_info "VNC service is needed, preparing xfce and vnc server..."

# Note: the length of password longer then 8
#       will be truncated to the length of 8
VNC_PASSWORD=vncpswd

install_if_dne tightvncserver

mkdir $HOME/.vnc

echo $VNC_PASSWORD | vncpasswd -f > $HOME/.vnc/passwd

sudo chmod 600 $HOME/.vnc/passwd

# Create an .Xauthority file
touch $HOME/.Xauthority

print_info "VNC environment is now set!"