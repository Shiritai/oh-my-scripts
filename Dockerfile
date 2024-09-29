ARG BASE_IMG="ubuntu:20.04"
FROM ${BASE_IMG}

ARG USER="user"
ENV USER "${USER}"

ARG TZ="Asia/Taipei"

ARG USER_PSWD="CHANGE_ME"
ENV USER_PSWD "${USER_PSWD}"

ARG USE_NO_VNC=no
ENV USE_NO_VNC "${USE_NO_VNC}"

ARG VNC_PSWD="vncpswd"
ENV VNC_PSWD "${VNC_PSWD}"

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE DontWarn

# Avoid warnings by switching to noninteractive for the build process
ENV DEBIAN_FRONTEND noninteractive

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone && \
    apt-get update -qq -y && apt-get upgrade -qq -y && \
    apt-get install -qq -y sudo unzip && \
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
COPY scripts/run-with-utils.sh /home/${USER}/scripts

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
RUN /home/${USER}/scripts/run-with-utils.sh \
    setup_all_plugins_in /home/${USER}/scripts/common

# Install custom plugins
RUN /home/${USER}/scripts/run-with-utils.sh \
    setup_all_plugins_in /home/${USER}/scripts/custom

# Install dev plugins
RUN /home/${USER}/scripts/run-with-utils.sh \
    setup_all_plugins_in /home/${USER}/scripts/dev

WORKDIR /home/${USER}

# set user password
RUN echo "${USER}:${USER_PSWD}" | sudo chpasswd
# clean up package cache
RUN sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD [ "./scripts/run-with-utils.sh", \
      "start_all_plugins_in", \
      "./scripts" ]
