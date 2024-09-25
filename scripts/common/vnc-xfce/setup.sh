#!/bin/bash

SCRIPT_DIR=$(realpath $(dirname $0))
# source all utils scripts
for item in $SCRIPT_DIR/../../utils/*.sh; do . $item; done

# only install vnc dependency if using vnc
if ! [ $USE_VNC = "yes" ]; then
    print_info "No VNC service needed"
    exit 0
fi

print_info "VNC service is needed, preparing xfce and vnc server..."

# Note: the length of password longer then 8
#       will be truncated to the length of 8
VNC_PASSWORD=vncpswd

sudo apt update -y

sudo apt install -y --no-install-recommends \
    xfce4 \
    xfce4-goodies \
    tightvncserver \
    dbus-x11 \
    xfonts-base

mkdir $HOME/.vnc

echo $VNC_PASSWORD | vncpasswd -f > $HOME/.vnc/passwd

sudo chmod 600 $HOME/.vnc/passwd

# Create an .Xauthority file
touch $HOME/.Xauthority

print_info "VNC environment is now set!"
