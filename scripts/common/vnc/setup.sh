#!/bin/bash

SCRIPT_DIR=$(realpath $(dirname $0))

# only install vnc dependency if using vnc
if ! [ $USE_VNC = "yes" ]; then
    print_info "VNC service is not needed"
    exit 0
fi

print_info "VNC service is needed, preparing vnc server..."

# Note: the length of password longer then 8
#       will be truncated to the length of 8
VNC_PSWD=${VNC_PSWD:-"vncpswd"}

# Install TigerVNC server
# TODO set VNC port in service file > exec command
# TODO check if it works with default config file
# NOTE tigervnc because of XKB extension: https://github.com/i3/i3/issues/1983
install_if_dne tigervnc-common \
               tigervnc-scraping-server \
               tigervnc-standalone-server \
               tigervnc-viewer \
               tigervnc-xorg-extension

if [ ${USE_SYSTEMD} = yes ]; then
    # Create tigervnc service file, with customizable user name, and enable it
    echo "# TODO wait for release of official service file: https://github.com/TigerVNC/tigervnc/pull/838
[Unit]
Description=TigerVNC remote desktop service
# TODO add dbus target? "systemctl --user start dbus" before starting gnome might fix logout issue
After=syslog.target network.target

[Service]
Type=simple
User=${USER}
PAMName=login
# NOTE %u not working for PIDFile since this is *not* "User=" https://www.freedesktop.org/software/systemd/man/systemd.unit.html#Specifiers
PIDFile=/home/${USER}/.vnc/%H%i.pid
ExecStartPre=/bin/sh -c '/usr/bin/vncserver -kill %i > /dev/null 2>&1 || :'
ExecStart=/usr/bin/vncserver %i -geometry 1920x1080 -depth 24 -localhost no -fg
ExecStop=/bin/sh -c '/usr/bin/vncserver -kill %i > /dev/null 2>&1 || :'

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/tigervnc@.service

    sudo systemctl enable tigervnc@:1
fi

# Setup vnc x11 startup
mkdir $HOME/.vnc
cp $SCRIPT_DIR/xstartup $HOME/.vnc

# Setup vnc password
echo $VNC_PSWD | vncpasswd -f > $HOME/.vnc/passwd
sudo chmod 600 $HOME/.vnc/passwd

print_info "VNC environment is now set"
