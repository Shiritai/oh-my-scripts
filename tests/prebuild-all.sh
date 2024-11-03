#!/bin/bash

# Directory of this script, a.k.a. `oh-my-scripts/tests`
SCRIPT_DIR=$(realpath $(dirname $0))

# Check all `$1` in `$2` directory and run docker build
prebuild_all() {
    print_info "Checking $2 for $1"
    for sub_element in $(ls -d $2/*); do
        if is_dir $sub_element; then
            prebuild_all $1 $sub_element
        elif ends_with $sub_element $1; then
            local WD=$(pwd)
            cd $(dirname $sub_element)
            local CUR=$(basename $(realpath .))
            print_info "Find $1 in $CUR, do you want to build this image? [y/N]"
            read ANS && [[ $ANS = 'Y' || $ANS = 'y' ]] && \
                sudo docker build -t oh-my-scripts:$CUR .
            cd $WD
        fi
    done
}

prebuild_all Dockerfile $SCRIPT_DIR
