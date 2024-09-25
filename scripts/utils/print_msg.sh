#!/bin/bash

print_info() {
    echo -e "[\e[1;34mINFO\e[0m] $1"
}

print_warning() {
    echo -e "[\e[1;33mINFO\e[0m] $1"
}

print_success() {
    echo -e "[\e[1;32mINFO\e[0m] $1"
}

print_failed() {
    echo -e "[\e[1;31mINFO\e[0m] $1"
}
