#!/bin/bash

# only install vnc dependency if using vnc
if ! [ $USE_NO_VNC = "yes" ]; then
    print_info "noVNC service is not needed"
    exit 0
fi

print_info "noVNC service is needed, preparing vnc server..."

# Note: the length of password longer then 8
#       will be truncated to the length of 8
VNC_PSWD=${VNC_PSWD:-"vncpswd"}

install_if_dne tightvncserver git libssl-dev

mkdir $HOME/.vnc

echo $VNC_PSWD | vncpasswd -f > $HOME/.vnc/passwd

sudo chmod 600 $HOME/.vnc/passwd

# Create an .Xauthority file
touch $HOME/.Xauthority

print_info "VNC environment is now set, setting up noVNC"

cd ~/
git clone https://github.com/novnc/noVNC.git
cd noVNC

echo "[ req ]
default_keyfile = privkey.pem
prompt = no
distinguished_name = req_1

[req_1]
C = TW
O = eroiko" > demo.conf

openssl req -new -x509 -days 365 -nodes -out self.pem -keyout self.pem -config demo.conf

print_info "noVNC environment is now set"
