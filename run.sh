#!/bin/bash

# Script dependencies: `zip` and `docker`

# Directory of this script, a.k.a. `oh-my-scripts`
SCRIPT_DIR=$(realpath $(dirname $0))

# Customizable variables
IMG_NAME=${IMG_NAME:-oh-my-c}
USE_VNC=${USE_VNC:-no} # yes or no
VNC_PORT=${VNC_PORT:-5901}

DEFAULT_CUSTOM_SCRIPTS_PATH=$SCRIPT_DIR/custom
# Path of custom scripts is also customizable.
# Your own custom scripts will be copied to `custom`
# directory of this repo everytime you run this script.
CUSTOM_SCRIPTS_PATH=$(realpath ${CUSTOM_SCRIPTS_PATH:-$DEFAULT_CUSTOM_SCRIPTS_PATH})

# Project path is customizable
USE_MOUNT_DIR=${USE_MOUNT_DIR:-no} # yes or no, no means do not mount volume
MOUNT_DIR=$(realpath ${MOUNT_DIR:-"$SCRIPT_DIR/data"})

# stack 1: ensure that we're running the script in correct directory
OLD_DIR=$pwd
cd $SCRIPT_DIR

# stack 1.5: copy custom scripts if the path is assigned
# Note: the copied custom scripts will not be removed automatically
# since we can't make sure which file/directory in custom is
# placed by the user or copied by this scripts
if [[ $CUSTOM_SCRIPTS_PATH != $DEFAULT_CUSTOM_SCRIPTS_PATH ]] ; then
    cp -r ${CUSTOM_SCRIPTS_PATH}/* $SCRIPT_DIR/scripts/custom
fi

# stack 2: zip scripts to a single file for image building
zip -r scripts.zip scripts

# stack 3: generate .dockerignore from docker-proto-ignore and .gitignore
cat proto.dockerignore .gitignore >> .dockerignore

# build docker image
sudo docker build -t $IMG_NAME \
                  --build-arg USER="${USER}" \
                  --build-arg USE_VNC="${USE_VNC}" \
                  .

# stack 3: remove temporary .dockerignore
rm .dockerignore

# stack 2: remove generated zip file
rm scripts.zip

# run container
sudo docker run -d -it \
                $([[ $USE_MOUNT_DIR = "yes" ]] && echo "-v $MOUNT_DIR:/home/${USER}/data") \
                $([[ $USE_VNC = "yes" ]] && echo "-p $VNC_PORT:5901") \
                --name ${IMG_NAME} \
                ${IMG_NAME} /home/${USER}/scripts/start.sh

# stack 1: go back to old working directory
cd $OLD_DIR
