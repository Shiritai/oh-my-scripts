#!/bin/bash

# Unpack zipped plugin directory (copied from host) and invoke installation.
# The zipped file is always located in `$HOME/scripts`
# and named `$HOME/scripts-${__PKG__}.zip`
__PKG__=$1

sudo chown -R ${USER} $HOME/scripts
sudo unzip $HOME/scripts-${__PKG__}.zip -d $HOME/scripts/${__PKG__}
rm $HOME/scripts-${__PKG__}.zip

$HOME/scripts/run-with-utils.sh setup_all_plugins_in $HOME/scripts/${__PKG__}
