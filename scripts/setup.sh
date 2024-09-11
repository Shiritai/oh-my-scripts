#!/bin/bash

script_dir=$(realpath $(dirname $0))

# run setup script in common directory
for i in $(ls -d $script_dir/common/*/); do
    ${i%%/}/setup.sh;
done

# run setup script in custom directory
for i in $(ls -d $script_dir/custom/*/); do
    ${i%%/}/setup.sh;
done
