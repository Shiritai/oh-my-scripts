#!/bin/bash

IMG_NAME=oh-my-c
USERNAME=$(id -un)
SCRIPT_DIR=$(realpath $(dirname $0))

# stack 1: ensure that we're running the script in correct directory
OLD_DIR=$pwd
cd $SCRIPT_DIR

# stack 2: zip scripts to a single file for image building
zip -r scripts.zip scripts

# stack 3: generate .dockerignore from docker-proto-ignore and .gitignore
cat docker-proto-ignore .gitignore >> .dockerignore

# build docker image
sudo docker build -t $IMG_NAME \
                  --build-arg USERNAME="${USERNAME}" \
                  .

# stack 3: remove temporary .dockerignore
rm .dockerignore

# stack 2: remove generated zip file
rm scripts.zip

# run container
sudo docker run -d -it \
                -v ./data:/home/${USERNAME}/data \
                --name ${IMG_NAME} \
                ${IMG_NAME} ~/scripts/start.sh

# stack 1: go back to old working directory
cd $OLD_DIR