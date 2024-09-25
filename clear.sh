#!/bin/bash

rm scripts-*

sudo docker rm -f oh-my-c
sudo docker image remove -f oh-my-c