#!/bin/bash

script_dir=$(realpath $(dirname $0))

$script_dir/zsh/setup.sh
# run setup script in custom directory
for i in $(ls -d $script_dir/custom/*/); do
    ${i%%/}/setup.sh;
done
