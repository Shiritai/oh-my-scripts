#!/bin/bash

[[ $USE_VNC = "no" ]] && exit 0

RESOLUTION=1920x1080
HOSTNAME=$(hostname)

print_info 'Updating /etc/hosts file...'
print_info "127.0.1.1\t$HOSTNAME" | sudo tee /etc/hosts

print_info "Starting VNC server with resolution $RESOLUTION..."
vncserver -kill :1

# start vnc first
vncserver -geometry $RESOLUTION :1
print_info "VNC server started"

# then start noVNC
~/noVNC/utils/novnc_proxy --vnc :5901 --listen 6901 &

print_info "noVNC started"
