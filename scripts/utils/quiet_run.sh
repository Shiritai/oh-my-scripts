#!/bin/bash

quiet_run() {
    "$@"  > /dev/null 2>&1
}