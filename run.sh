#!/bin/bash

# customizable variables
IMG_NAME=oh-my-c
USE_VNC=no # yes or no

# stack 1: ensure that we're running the script in correct directory
SCRIPT_DIR=$(realpath $(dirname $0))
OLD_DIR=$pwd
cd $SCRIPT_DIR

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
                -v ./data:/home/${USER}/data \
                $([[ $USE_VNC = "yes" ]] && echo "-p 5901:5901") \
                --name ${IMG_NAME} \
                ${IMG_NAME} ~/scripts/start.sh

# stack 1: go back to old working directory
cd $OLD_DIR