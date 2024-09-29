#!/bin/bash

SCRIPT_DIR=$(realpath $(dirname $0))

rm $SCRIPT_DIR/scripts-*

sudo docker rm -f $1
sudo docker image remove -f $1