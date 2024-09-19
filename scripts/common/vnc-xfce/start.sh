#!/bin/bash

[[ $USE_VNC = "no" ]] && exit 0

RESOLUTION=1920x1080
HOSTNAME=$(hostname)

echo 'Updating /etc/hosts file...'
echo "127.0.1.1\t$HOSTNAME" | sudo tee /etc/hosts

echo "Starting VNC server at $RESOLUTION..."
vncserver -kill :1
vncserver -geometry $RESOLUTION &

echo "VNC server started at $RESOLUTION! ^-^"

echo "Starting tail -f /dev/null..."
tail -f /dev/null
