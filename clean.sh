#!/bin/bash

SCRIPT_DIR=$(realpath $(dirname $0))

rm $SCRIPT_DIR/scripts-*

# if name of container is assigned as the first argument
if ! [[ -z $1 ]]; then
    sudo docker rm -f $1
fi
