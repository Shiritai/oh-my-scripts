#!/bin/bash

# Script dependencies: `zip` and `docker`

# Directory of this script, a.k.a. `oh-my-scripts`
SCRIPT_DIR=$(realpath $(dirname $0))

# Customizable variables
BASE_IMG=${BASE_IMG:-"ubuntu:20.04"}
IMG_NAME=${IMG_NAME:-oh-my-c}
USE_GPU=${USE_VNC:-yes} # yes or no
USE_VNC=${USE_VNC:-no} # yes or no
VNC_PORT=${VNC_PORT:-5901} # port of host to open as vnc

# oh-my-scripts running mode
# b: build only
# r: run only
# br: build and run
OMS_MODE=${OMS_MODE:-br}

get_absolute_path_if_is_relative() {
    if [[ "$1" = /* ]]; then # absolute, do nothing
        echo $1
    else # relative, convert to absolute
        echo $(realpath $1)
    fi
}

DEFAULT_CUSTOM_SCRIPTS_PATH=$SCRIPT_DIR/scripts/custom
CUSTOM_SCRIPTS_PATH=${CUSTOM_SCRIPTS_PATH:-$DEFAULT_CUSTOM_SCRIPTS_PATH}
# Path of custom scripts is also customizable.
# Your own custom scripts will be copied to `custom`
# directory of this repo everytime you run this script.
# If `CUSTOM_SCRIPTS_PATH` is relative (and is definetly
# assigned by user), make it absolute
CUSTOM_SCRIPTS_PATH=$(get_absolute_path_if_is_relative $CUSTOM_SCRIPTS_PATH)

echo $CUSTOM_SCRIPTS_PATH

# Mount path is customizable.
# Assign `USE_MOUNT_DIR=yes` to enable mount path.
USE_MOUNT_DIR=${USE_MOUNT_DIR:-no} # yes or no, no means do not mount volume
MOUNT_DIR=${MOUNT_DIR:-"$SCRIPT_DIR/data"}
# After `USE_MOUNT_DIR=yes`, assign `MOUNT_DIR=VOLUME_TO_MOUNT`.
# If `MOUNT_DIR` is relative (and is definetly
# assigned by user), make it absolute.
MOUNT_DIR=$(get_absolute_path_if_is_relative $MOUNT_DIR)

# stack 1: ensure that we're running the script in correct directory
OLD_DIR=$pwd
cd $SCRIPT_DIR

# stack 1.5: copy custom scripts if the path is assigned
# Note: the copied custom scripts will not be removed automatically
# since we can't make sure which file/directory in custom is
# placed by the user or copied by this scripts
if [[ $CUSTOM_SCRIPTS_PATH != $DEFAULT_CUSTOM_SCRIPTS_PATH ]] ; then
    cp -r ${CUSTOM_SCRIPTS_PATH}/* $DEFAULT_CUSTOM_SCRIPTS_PATH
fi

# stack 2: zip scripts to a single file for image building
# zip util scripts once, since files here seldom changes
if ! [[ -f scripts-utils.zip ]]; then zip -r scripts-utils.zip scripts/utils; fi
# zip common scripts once, since files here seldom changes
if ! [[ -f scripts-common.zip ]]; then zip -r scripts-common.zip scripts/common; fi
# zip custom scripts once, since files here seldom changes
if ! [[ -f scripts-custom.zip ]]; then zip -r scripts-custom.zip scripts/custom; fi
# re-zip dev (custom) scripts everytime
zip -r scripts-dev.zip scripts/dev

# stack 3: generate .dockerignore from docker-proto-ignore and .gitignore
cat proto.dockerignore .gitignore >> .dockerignore

if [[ $OMS_MODE = "b" || $OMS_MODE = "br" ]]; then
    # build docker image
    sudo docker build -t $IMG_NAME \
                    --platform linux/amd64 \
                    --build-arg BASE_IMG="${BASE_IMG}" \
                    --build-arg USER="${USER}" \
                    --build-arg USE_VNC="${USE_VNC}" \
                    .
fi

# stack 3: remove temporary .dockerignore
rm .dockerignore

# stack 2: remove generated zip file
rm scripts-dev.zip

if [[ $OMS_MODE = "r" || $OMS_MODE = "br" ]]; then
    # run container
    sudo docker run -d -it \
                    $([[ $USE_MOUNT_DIR = "yes" ]] && echo "-v $MOUNT_DIR:/home/${USER}/data") \
                    $([[ $USE_VNC = "yes" ]] && echo "-p $VNC_PORT:5901") \
                    $([[ $USE_GPU = "yes" ]] && echo "--runtime=nvidia --gpus all") \
                    --privileged \
                    --name ${IMG_NAME} \
                    ${IMG_NAME} bash
                    # ${IMG_NAME} /home/${USER}/scripts/start.sh
fi

# stack 1: go back to old working directory
cd $OLD_DIR
