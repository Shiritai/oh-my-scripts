#!/bin/bash

SCRIPT_DIR=$(realpath $(dirname $0))

INSTALL_CMD="sudo apt install -y"
UPDATE_CMD="sudo apt update -y"

source $SCRIPT_DIR/../../utils.sh

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
    if [ ! -d ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins ]
    then
        print_info "Omz directory DNE, installing oh-my-zsh and corresponding plugins"
        yes | sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
        # setup zsh script, notice that zshrc is set by oh-my-zsh
        # we should override .zshrc even if it exists
        cp $SCRIPT_DIR/.zshrc ~
    fi
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
