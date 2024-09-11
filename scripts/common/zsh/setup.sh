#!/bin/bash

script_dir=$(realpath $(dirname $0))

# Debian series
install_cmd="sudo apt install -y"
update_cmd="sudo apt update -y"
# Arch series
# install_cmd="sudo pacman -S --noconfirm"
# update_cmd="sudo pacman -Syu --noconfirm"

print_info() {
    echo -e "[\e[1;34mINFO\e[0m] $1"
}

check_and_install() {
    if ! command -v $1 > /dev/null
    then
        print_info "$1 DNE, installing them..."
        $install_cmd -y $1
    fi
}

# install packages I prefer :)
check_or_install_pkg() {
    $update_cmd
    prefer_pkg="vim unzip"
    for item in ${prefer_pkg}; do
        check_and_install "${item}"
    done
}

# setup oh-my-zsh and its dependencies
check_or_install_omz() {
    needed_pkg="zsh git curl"
    # install zsh and needed commands
    for item in ${needed_pkg}; do
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
        cp $script_dir/.zshrc ~
    fi
}

# setup zsh scripts
check_or_setup_scripts() {
    # setup powerlevel10k script
    if [ ! -f ~/.p10k.zsh ]
    then
        print_info "$USER haven't use p10k yet, setting up p10k..."
        cp $script_dir/.p10k.zsh ~
    fi

    # setup zsh script
    if [ ! -f ~/.zshrc ]
    then
        print_info "$USER haven't use zsh yet, setting up zsh..."
        cp $script_dir/.zshrc ~
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
