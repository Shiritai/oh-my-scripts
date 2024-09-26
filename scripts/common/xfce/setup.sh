#!/bin/bash

sudo apt update -y

sudo DEBIAN_FRONTEND=noninteractive apt install -y \
    x11-utils \
    xfce4 \
    xfce4-goodies \
    xfce4-terminal \
    xclip \
    dbus-x11
