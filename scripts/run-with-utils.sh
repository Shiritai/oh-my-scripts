#!/bin/bash

SCRIPT_DIR=$(realpath $(dirname $0))

set -a
for item in $SCRIPT_DIR/utils/*.sh; do . $item; done
$@
set +a
