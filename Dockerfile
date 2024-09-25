ARG BASE_IMG="ubuntu:20.04"
FROM ${BASE_IMG}

ARG USER="user"
ENV USER "${USER}"

ARG TZ="Asia/Taipei"

ARG USE_VNC=no
ENV USE_VNC "${USE_VNC}"

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE DontWarn

# Avoid warnings by switching to noninteractive for the build process
ENV DEBIAN_FRONTEND noninteractive

RUN echo ${USER} && \
    ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone && \
    apt update && apt upgrade -y && \
    apt install sudo unzip -y && \
    useradd -m -G sudo "${USER}" && \
    echo "${USER} ALL = NOPASSWD: ALL" > /etc/sudoers.d/"${USER}" && \
    chmod 0440 /etc/sudoers.d/"${USER}" && \
    passwd -d "${USER}" && \
    mkdir /home/${USER}/scripts

USER "${USER}"

COPY scripts-utils.zip /home/${USER}
RUN sudo chown -R ${USER} /home/${USER}/scripts && \
    sudo unzip /home/${USER}/scripts-utils.zip -d /home/${USER} && \
    rm /home/${USER}/scripts-utils.zip

# Install common plugins
COPY scripts-common.zip /home/${USER}
RUN sudo unzip /home/${USER}/scripts-common.zip -d /home/${USER} && \
    rm /home/${USER}/scripts-common.zip
# source all utils and run setup scripts in common
RUN . /home/${USER}/scripts/utils/install_all_plugins_in.sh && \
    install_all_plugins_in /home/${USER}/scripts/common

# Install custom plugins
COPY scripts-custom.zip /home/${USER}
RUN sudo unzip /home/${USER}/scripts-custom.zip -d /home/${USER} && \
    rm /home/${USER}/scripts-custom.zip
# source all utils and run setup scripts in custom
RUN . /home/${USER}/scripts/utils/install_all_plugins_in.sh && \
    install_all_plugins_in /home/${USER}/scripts/custom

# Install dev plugins
COPY scripts-dev.zip /home/${USER}
RUN sudo unzip /home/${USER}/scripts-dev.zip -d /home/${USER} && \
    rm /home/${USER}/scripts-dev.zip
# source all utils and run setup scripts in dev
RUN . /home/${USER}/scripts/utils/install_all_plugins_in.sh && \
    install_all_plugins_in /home/${USER}/scripts/dev

WORKDIR /home/${USER}

RUN sudo apt clean && \
    sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD [ "bash" ]