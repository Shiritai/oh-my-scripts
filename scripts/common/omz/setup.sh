#!/bin/bash

# only install ssh dependency if using it
if ! [ $USE_OMZ = "yes" ]; then
    print_info "oh-my-zsh is not needed"
    exit 0
fi

print_info "Need oh-my-zsh, installing it"

SCRIPT_DIR=$(realpath $(dirname $0))

# setup oh-my-zsh and its dependencies
check_or_install_omz() {
    # set zsh as default shell
    if ! cat /etc/passwd | grep $USER | grep zsh > /dev/null
    then
        print_info "Zsh is not default shell, set as default"
        chsh -s $(which zsh)
    fi

    # setup oh-my-zsh environment and plugins
    local _ZSH_CUSTOM=${ZSH:-~/.oh-my-zsh}/custom
    if [ ! -d ${_ZSH_CUSTOM}/plugins ]
    then
        print_info "Omz directory DNE, installing oh-my-zsh and corresponding plugins"
        yes | sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi

    # check existence of all themes and plugins, download if DNE
    local tars=( "${_ZSH_CUSTOM}/plugins/zsh-completions" "${_ZSH_CUSTOM}/plugins/zsh-autosuggestions" "${_ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" "${_ZSH_CUSTOM}/themes/powerlevel10k" )
    local links=( zsh-users/zsh-completions zsh-users/zsh-autosuggestions zsh-users/zsh-syntax-highlighting romkatv/powerlevel10k )
    for i in "${!tars[@]}"; do
        print_info "Checking ${tars[$i]}..."
        if [ ! -d ${tars[$i]} ] ; then
            git clone https://github.com/${links[$i]} ${tars[$i]}
        fi
    done

    # download and install meslo nerd font
    links=( MesloLGS%20NF%20Regular.ttf MesloLGS%20NF%20Bold.ttf MesloLGS%20NF%20Italic.ttf MesloLGS%20NF%20Bold%20Italic.ttf )
    for i in "${!links[@]}"; do
        sudo wget -P /usr/local/share/fonts \
            "https://github.com/romkatv/powerlevel10k-media/raw/master/${links[$i]}" \
            > /dev/null 2>&1
    done
    fc-cache -fv > /dev/null
}

# setup zsh scripts
check_or_setup_scripts() {
    # setup dotfiles
    for item in $(ls -d $SCRIPT_DIR/.*); do
        if [ -f $item ]
        then
            print_info "Find zsh-related dotfile: $item, put it into ${HOME}"
            cp $item ~
        fi
    done
}

install_if_dne vim unzip zsh git curl wget fontconfig
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
