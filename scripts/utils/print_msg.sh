#!/bin/bash

print_info() {
    echo -e "[\e[1;34mINFO\e[0m] $@"
}

print_warning() {
    echo -e "[\e[1;33mWARN\e[0m] $@"
}

print_debug() {
    echo -e "[\e[1;32mDEBG\e[0m] $@"
}

print_failed() {
    echo -e "[\e[1;31mFAIL\e[0m] $@"
}
