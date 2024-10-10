#!/bin/bash

SCRIPT_DIR=$(realpath $(dirname $0))

# only install noVNC dependency if using it
if ! [ $USE_NO_VNC = "yes" ]; then
    print_info "noVNC service is not needed"
    exit 0
fi

print_info "setting up noVNC"

install_if_dne git

cd /usr/share
sudo git clone https://github.com/novnc/noVNC.git
cd noVNC

# Make sure that $SSL_REQ_CONFOG_FILE exists
SSL_REQ_CONFOG_FILE=$SCRIPT_DIR/openssl-req.conf
if ! [[ -f $SSL_REQ_CONFOG_FILE ]]; then
    sudo cp $SSL_REQ_CONFOG_FILE.sample $SSL_REQ_CONFOG_FILE
fi

sudo openssl req -new \
                 -x509 \
                 -days 365 \
                 -nodes \
                 -out self.pem \
                 -keyout self.pem \
                 -config $SSL_REQ_CONFOG_FILE

# clone websockify
cd utils
sudo git clone https://github.com/novnc/websockify

if [[ ${USE_SYSTEMD} = yes ]]; then
    echo "[Unit]
Description=noVNC remote desktop server
After=tigervnc@:1.service

[Service]
Type=simple
User=${USER}
ExecStart=/usr/share/noVNC/utils/novnc_proxy --vnc :5901 --listen 6901

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/novnc.service

    sudo systemctl enable novnc
fi

print_info "Install numpy for better noVNC performance"

# install pip & install numpy for better
# noVNC performance, dependent: websockify
install_if_dne python3-pip
yes | pip3 install numpy

print_info "noVNC environment is now set"
