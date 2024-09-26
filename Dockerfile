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

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

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

# copy scripts to container
COPY scripts-utils.zip /home/${USER}
COPY scripts-common.zip /home/${USER}
COPY scripts-custom.zip /home/${USER}
COPY scripts-dev.zip /home/${USER}

RUN sudo chown -R ${USER} /home/${USER}/scripts && \
    sudo unzip /home/${USER}/scripts-utils.zip -d /home/${USER} && \
    rm /home/${USER}/scripts-utils.zip && \
    sudo unzip /home/${USER}/scripts-common.zip -d /home/${USER} && \
    rm /home/${USER}/scripts-common.zip && \
    sudo unzip /home/${USER}/scripts-custom.zip -d /home/${USER} && \
    rm /home/${USER}/scripts-custom.zip && \
    sudo unzip /home/${USER}/scripts-dev.zip -d /home/${USER} && \
    rm /home/${USER}/scripts-dev.zip

# Install common plugins
RUN . /home/${USER}/scripts/utils/install_all_plugins_in.sh && \
    install_all_plugins_in /home/${USER}/scripts/common

# Install custom plugins
RUN . /home/${USER}/scripts/utils/install_all_plugins_in.sh && \
    install_all_plugins_in /home/${USER}/scripts/custom

# Install dev plugins
RUN . /home/${USER}/scripts/utils/install_all_plugins_in.sh && \
    install_all_plugins_in /home/${USER}/scripts/dev

WORKDIR /home/${USER}

RUN sudo apt clean && \
    sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD [ "bash" ]