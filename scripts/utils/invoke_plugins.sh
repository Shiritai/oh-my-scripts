#!/bin/bash

# Invoke all scripts named `$1` in `$2` directory
invoke_all_plugins_scripts_in() {
    print_info "Checking $2 for $1"
    for sub_element in $(ls -d $2/*); do
        if is_dir $sub_element; then
            invoke_all_plugins_scripts_in $1 $sub_element
        elif ends_with $sub_element $1; then
            print_info "Find $1: $sub_element"
            $sub_element
        fi
    done
}

setup_all_plugins_in() {
    invoke_all_plugins_scripts_in setup.sh $1
}
