#!/bin/bash

starts_with() {
    echo $1 | quiet_run grep "^$2"
}

ends_with() {
    echo $1 | quiet_run grep "$2$"
}

match_with() {
    echo $1 | quiet_run grep "^$2$"
}

is_dir() {
    test -d $1
}

is_file() {
    test -f $1
}