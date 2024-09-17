FROM --platform=linux/amd64 ubuntu:24.04

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
    mkdir /home/${USER}/data

USER "${USER}"

COPY scripts.zip /home/${USER}
RUN sudo unzip /home/${USER}/scripts.zip -d /home/${USER}
RUN /home/${USER}/scripts/setup.sh && \
    rm /home/${USER}/scripts.zip

WORKDIR /home/${USER}

RUN sudo apt clean && \
    sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD [ "bash" ]