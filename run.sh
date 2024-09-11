#!/bin/bash

IMG_NAME=oh-my-c
USERNAME=$(id -un)
script_dir=$(realpath $(dirname $0))

OLD_DIR=$pwd
cd $script_dir

# zip scripts to a single file for image building
zip -r scripts.zip scripts

sudo docker build -t $IMG_NAME \
                  --build-arg USERNAME="${USERNAME}" \
                  .

# remove generated zip file
rm scripts.zip

sudo docker run -d -it \
                -v ./data:/home/${USERNAME}/data \
                --name ${IMG_NAME} \
                ${IMG_NAME} bash

cd $OLD_DIR