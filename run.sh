#!/bin/bash

# oh-my-scripts: (in short: `oms`)
#   The scripting tool for container environment build-up development. OH MY SCRIPTS!!!
OMS_VERSION='0.1.0'

# See `print_help` function for more information
# p.s. dependencies: `zip` and `docker`

# ----------- [Customizable Parameters] -----------

BASE_IMG=${BASE_IMG:-'ubuntu:20.04'}
IMG_NAME=${IMG_NAME:-'oh-my-c'}
CONTAINER_NAME=${CONTAINER_NAME:-$IMG_NAME}

LOCALE=${LOCALE:-$((locale -a | grep -v C | grep -v POSIX | head -n 1) || echo '')}
TZ=${TZ:-$(timedatectl show | grep -E 'Timezone=' | grep -E -o '[a-zA-Z]+\/[a-zA-Z]+' 2>/dev/null || echo "")}

# Systemd support
USE_SYSTEMD=${USE_SYSTEMD:-'yes'} # yes or no

# Username of the container
USERNAME=${USERNAME:-$USER}
# Change user password if needed
USE_USER_PSWD=${USE_USER_PSWD:-'no'}
USER_PSWD=${USER_PSWD:-'CHANGE_ME'}

USE_GPU=${USE_GPU:-'no'} # yes or no

USE_NO_VNC=${USE_NO_VNC:-'no'} # yes or no
# port of host to open for noVNC
NO_VNC_PORT=${NO_VNC_PORT:-'none'}

USE_VNC=${USE_VNC:-$USE_NO_VNC} # yes or no
VNC_PSWD=${VNC_PSWD:-'vncpswd'}
# port of host to open for vnc,
# default to none (not open) since ssh is more handy
VNC_PORT=${VNC_PORT:-'none'}

USE_SSH=${USE_SSH:-no} # yes or no
# port of host to open for ssh
SSH_PORT=${SSH_PORT:-'none'}

# use oh-my-zsh
USE_OMZ=${USE_OMZ:-'no'} # yes or no

# use gnome GUI
USE_GUI=${USE_GUI:-'no'} # yes or no

# use (GUI) app
USE_APP=${USE_APP:-'no'} # yes or no

# Mount path is customizable.
# Assign `USE_MOUNT_DIR=yes` to enable mount path.
USE_MOUNT_DIR=${USE_MOUNT_DIR:-'no'} # yes or no, no means do not mount volume
MOUNT_DIR=${MOUNT_DIR:-"$SCRIPT_DIR/data"}

# Additional arguments to feed to docker build as a plain string
BUILD_ADDITIONAL_ARGS=${BUILD_ADDITIONAL_ARGS:-''}

# Additional arguments to feed to docker run as a plain string
RUN_ADDITIONAL_ARGS=${RUN_ADDITIONAL_ARGS:-''}

# ----------- [Path related Parameters] -----------

# Directory of this script, a.k.a. `oh-my-scripts`
SCRIPT_DIR=$(realpath $(dirname $0))

# Path of custom scripts is customizable
CUSTOM_SCRIPTS_PATH=${CUSTOM_SCRIPTS_PATH:-"$SCRIPT_DIR/scripts/custom"}

# Path of dev scripts is customizable
DEV_SCRIPTS_PATH=${DEV_SCRIPTS_PATH:-"$SCRIPT_DIR/scripts/dev"}

# oh-my-scripts running mode
# b: build only
# r: run only
# br: build and run
# h: print help
# d: dry-run
OMS_MODE=${OMS_MODE:-'h'}

# ----------- [Util Part] -----------

# print help messages
print_help() {
    echo "oh-my-scripts:
    The scripting tool for container environment build-up development. OH MY SCRIPTS!!!

Usage: OMS_MODE=<MODE_FLAGs> [ARG=VALUE]... ./run.sh

Possible <MODE_FLAGs>:
    b: build image
    r: run container
    br: build image and run container
    d: dry-run mode, will only shows all the arguments in json form without conducting any real sction
    h: print this help message and exit

For all possible [ARG=VALUE]s, please refer to the parameter part of this scripts
"
}

# print summary in json form
print_all_args() {
    echo "{
    \"BASE_IMG\": \"$BASE_IMG\",
    \"IMG_NAME\": \"$IMG_NAME\",
    \"CONTAINER_NAME\": \"$CONTAINER_NAME\",
    \"LOCALE\": \"$LOCALE\",
    \"TZ\": \"$TZ\",
    \"USE_SYSTEMD\": \"$USE_SYSTEMD\",
    \"USERNAME\": \"$USERNAME\",
    \"USE_USER_PSWD\": \"$USE_USER_PSWD\",
    \"USER_PSWD\": \"$USER_PSWD\",
    \"USE_GPU\": \"$USE_GPU\",
    \"USE_NO_VNC\": \"$USE_NO_VNC\",
    \"NO_VNC_PORT\": \"$NO_VNC_PORT\",
    \"USE_VNC\": \"$USE_VNC\",
    \"VNC_PORT\": \"$VNC_PORT\",
    \"USE_SSH\": \"$USE_SSH\",
    \"SSH_PORT\": \"$SSH_PORT\",
    \"USE_OMZ\": \"$USE_OMZ\",
    \"USE_GUI\": \"$USE_GUI\",
    \"USE_APP\": \"$USE_APP\",
    \"USE_MOUNT_DIR\": \"$USE_MOUNT_DIR\",
    \"MOUNT_DIR\": \"$MOUNT_DIR\",
    \"BUILD_ADDITIONAL_ARGS\": \"$BUILD_ADDITIONAL_ARGS\",
    \"RUN_ADDITIONAL_ARGS\": \"$RUN_ADDITIONAL_ARGS\",
    \"RUN_ADDITIONAL_ARGS\": \"$RUN_ADDITIONAL_ARGS\",
    \"CUSTOM_SCRIPTS_PATH\": \"$CUSTOM_SCRIPTS_PATH\",
    \"DEV_SCRIPTS_PATH\": \"$DEV_SCRIPTS_PATH\",
    \"OMS_MODE\": \"$OMS_MODE\",
    \"OMS_VERSION\": \"$OMS_VERSION\"
}"
}

get_absolute_path_if_is_relative() {
    if [[ "$1" = /* ]]; then # absolute, do nothing
        echo $1
    else # relative, convert to absolute
        echo $(realpath $1)
    fi
}

# Extract directory $2 to zip file named $1
dir_to_zip() {
    local PATH_BEFORE_EXTRACT=$(pwd)
    cd $2
    zip -r $1 .
    mv $1 ${PATH_BEFORE_EXTRACT}
    cd ${PATH_BEFORE_EXTRACT}
}

# ----------- [Pre-processing Part] -----------

# If `CUSTOM_SCRIPTS_PATH` is relative (and is definetly
# assigned by user), make it absolute
CUSTOM_SCRIPTS_PATH=$(get_absolute_path_if_is_relative $CUSTOM_SCRIPTS_PATH)

# If `DEV_SCRIPTS_PATH` is relative (and is definetly
# assigned by user), make it absolute
DEV_SCRIPTS_PATH=$(get_absolute_path_if_is_relative $DEV_SCRIPTS_PATH)

# After `USE_MOUNT_DIR=yes`, assign `MOUNT_DIR=VOLUME_TO_MOUNT`.
# If `MOUNT_DIR` is relative (and is definetly
# assigned by user), make it absolute.
MOUNT_DIR=$(get_absolute_path_if_is_relative $MOUNT_DIR)

# ----------- [Confirmation Part] -----------

if [[ $OMS_MODE = *'h'* ]]; then
    print_help
    exit
fi

# print dry-run messages
print_all_args
if [[ $OMS_MODE = *'d'* ]]; then
    # if in dry-run mode, quit after print
    exit
fi

# ----------- [Execution Part] -----------

# stack 1: ensure that we're running the script in correct directory
OLD_DIR=$pwd
cd $SCRIPT_DIR

if [[ $OMS_MODE = *'b'* && $OMS_MODE != *'d'* ]]; then
    # stack 2: zip scripts to a single file for image building
    # zip util scripts once, since files here seldom changes
    if ! [[ -f scripts-utils.zip ]]; then dir_to_zip scripts-utils.zip scripts/utils; fi
    # zip core scripts once, since files here seldom changes
    if ! [[ -f scripts-core.zip ]]; then dir_to_zip scripts-core.zip scripts/core; fi
    # zip common scripts once, since files here seldom changes
    if ! [[ -f scripts-common.zip ]]; then dir_to_zip scripts-common.zip scripts/common; fi
    # zip custom scripts once, since files here seldom changes
    if ! [[ -f scripts-custom.zip ]]; then dir_to_zip scripts-custom.zip $CUSTOM_SCRIPTS_PATH; fi
    # zip app scripts once, since files here seldom changes
    if ! [[ -f scripts-app.zip && $USE_APP = "yes" ]]; then dir_to_zip scripts-app.zip scripts/app; fi
    # re-zip dev scripts everytime
    dir_to_zip scripts-dev.zip $DEV_SCRIPTS_PATH

    # stack 3: generate .dockerignore from docker-proto-ignore and .gitignore
    cat .gitignore proto.dockerignore >> .dockerignore

    # build docker image
    sudo docker build -t $IMG_NAME \
                      --build-arg BASE_IMG="${BASE_IMG}" \
                      --build-arg LOCALE="${LOCALE}" \
                      --build-arg TZ="${TZ}" \
                      --build-arg USE_SYSTEMD="${USE_SYSTEMD}" \
                      --build-arg USER="${USERNAME}" \
                      --build-arg USE_SSH="${USE_SSH}" \
                      --build-arg USE_VNC="${USE_VNC}" \
                      --build-arg VNC_PSWD="${VNC_PSWD}" \
                      --build-arg USE_NO_VNC="${USE_NO_VNC}" \
                      --build-arg USE_OMZ="${USE_OMZ}" \
                      --build-arg USE_GUI="${USE_GUI}" \
                      --build-arg USE_APP="${USE_APP}" \
                      --build-arg USE_USER_PSWD="${USE_USER_PSWD}" \
                      --build-arg USER_PSWD="${USER_PSWD}" \
                      $(! [[ -z ${BUILD_ADDITIONAL_ARGS} ]] && echo "${BUILD_ADDITIONAL_ARGS}") \
                      . 2>&1 | tee build.log

    # stack 3: remove temporary .dockerignore
    rm .dockerignore

    # stack 2: remove generated zip file
    rm scripts-dev.zip
fi

if [[ $OMS_MODE = *'r'* && $OMS_MODE != *'d'* ]]; then
    # run container
    sudo docker run -d -it \
                    $([[ $USE_MOUNT_DIR = 'yes' ]] && echo "-v $MOUNT_DIR:/home/${USER}/data") \
                    $([[ $USE_GPU = 'yes' ]] && echo "--gpus all") \
                    $([[ $USE_SYSTEMD = 'yes' ]] && echo "--tmpfs /run --tmpfs /run/lock --tmpfs /tmp
                                                        --cap-add SYS_BOOT --cap-add SYS_ADMIN
                                                        --cgroupns host -v /sys/fs/cgroup:/sys/fs/cgroup") \
                    $([[ $USE_VNC = 'yes' && $VNC_PORT != 'none' ]] && echo "-p $VNC_PORT:5901") \
                    $([[ $USE_NO_VNC = 'yes' && $NO_VNC_PORT != 'none' ]] && echo "-p $NO_VNC_PORT:6901") \
                    $([[ $USE_SSH = 'yes' && $SSH_PORT != 'none' ]] && echo "-p $SSH_PORT:22") \
                    $(echo ${RUN_ADDITIONAL_ARGS}) \
                    -h ${CONTAINER_NAME} \
                    --name ${CONTAINER_NAME} \
                    ${IMG_NAME} $([[ $USE_SYSTEMD = 'yes' ]] && echo "/sbin/init")
fi

# stack 1: go back to old working directory
cd $OLD_DIR
