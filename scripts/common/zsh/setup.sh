#!/bin/bash

SCRIPT_DIR=$(realpath $(dirname $0))
source $SCRIPT_DIR/../../utils/*.sh

INSTALL_CMD="sudo apt install -y"
UPDATE_CMD="sudo apt update -y"

# install packages I prefer :)
check_or_install_pkg() {
    $UPDATE_CMD
    PREFER_PKG="vim unzip"
    for item in ${PREFER_PKG}; do
        check_and_install "${item}"
    done
}

# setup oh-my-zsh and its dependencies
check_or_install_omz() {
    NEEDED_PKG="zsh git curl"
    # install zsh and needed commands
    for item in ${NEEDED_PKG}; do
        check_and_install "${item}"
    done

    # set zsh as default shell
    if ! cat /etc/passwd | grep $USER | grep zsh > /dev/null
    then
        print_info "Zsh is not default shell, set as default"
        chsh -s $(which zsh)
    fi

    # setup oh-my-zsh environment and plugins
    _ZSH_CUSTOM=${ZSH:-~/.oh-my-zsh}/custom
    if [ ! -d ${_ZSH_CUSTOM}/plugins ]
    then
        print_info "Omz directory DNE, installing oh-my-zsh and corresponding plugins"
        yes | sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi

    # check existence of all themes and plugins, download if DNE
    tars=( "${_ZSH_CUSTOM}/plugins/zsh-completions" "${_ZSH_CUSTOM}/plugins/zsh-autosuggestions" "${_ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" "${_ZSH_CUSTOM}/themes/powerlevel10k" )
    links=( zsh-users/zsh-completions zsh-users/zsh-autosuggestions zsh-users/zsh-syntax-highlighting romkatv/powerlevel10k )
    for i in "${!tars[@]}"; do
        print_info "Checking ${tars[$i]}..."
        if [ ! -d ${tars[$i]} ] ; then git clone https://github.com/${links[$i]} ${tars[$i]} ; fi
    done
    
    # setup zsh script, notice that zshrc is set by oh-my-zsh
    # we should override .zshrc even if it exists
    cp $SCRIPT_DIR/.zshrc ~
}

# setup zsh scripts
check_or_setup_scripts() {
    # setup powerlevel10k script
    if [ ! -f ~/.p10k.zsh ]
    then
        print_info "$USER haven't use p10k yet, setting up p10k..."
        cp $SCRIPT_DIR/.p10k.zsh ~
    fi

    # setup zsh script
    if [ ! -f ~/.zshrc ]
    then
        print_info "$USER haven't use zsh yet, setting up zsh..."
        cp $SCRIPT_DIR/.zshrc ~
    fi
}

check_or_install_pkg
check_or_install_omz
check_or_setup_scripts

# enter zsh
if ! echo $SHELL | grep zsh
then
    print_info "Entering zsh"
    zsh
else
    print_info "Shell customization is set :)"
fi
