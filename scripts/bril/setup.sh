#!/bin/bash

script_dir=$(realpath $(dirname $0))

# install dependencies
sudo apt update -y && \
    sudo apt upgrade -y && \
    sudo apt install git curl unzip pip -y

# setup shell (bash and zsh)
cp ${script_dir}/.bril.sh ~
_CMD=$(echo -e "\nsource ~/.bril.sh\n")
echo $_CMD >> ~/.bashrc
echo $_CMD >> ~/.zshrc
source ~/.bril.sh

# prepare repo for installation
mkdir -p ~/repos
BRIL_REPO=~/repos/bril
mkdir -p $BRIL_REPO
sudo git clone https://github.com/sampsyo/bril.git $BRIL_REPO

# install deno and brili
curl -fsSL https://deno.land/install.sh | sh
deno install ${BRIL_REPO}/brili.ts

# install flit and bril2xxx
pip install --user flit
cd ${BRIL_REPO}/bril-txt && flit install --symlink --user
