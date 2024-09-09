#!/bin/bash

IMG_NAME=acd-hw
USERNAME=$(id -un)
script_dir=$(realpath $(dirname $0))

OLD_DIR=$pwd
cd $script_dir

# zip scripts to a single file for image building
zip -r scripts.zip scripts

sudo docker build -t $IMG_NAME \
                  --build-arg USERNAME="${USERNAME}" \
                  .

sudo docker run -d -it \
                -v ./data:/home/${USERNAME}/data \
                ${IMG_NAME} bash

# remove ghenerated zip file
rm scripts.zip

cd $OLD_DIR