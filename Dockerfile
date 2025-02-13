ARG BASE_IMG="ubuntu:20.04"
FROM ${BASE_IMG}

ENV container=docker
ENV DEBIAN_FRONTEND=noninteractive

# Setup user, after sudo user created and set,
# the commands that needs root priviledge needs "sudo"
ARG USER="user"
ARG HOME="/home/$USER"
ENV USER="${USER}"
RUN echo -e "[\e[1;34mINFO\e[0m] Setup user $USER" && \
    apt-get update -qq -y && \
    apt-get install -qq -y sudo unzip && \
    useradd -m -G sudo "${USER}" && \
    echo "${USER} ALL = NOPASSWD: ALL" > /etc/sudoers.d/"${USER}" && \
    chmod 0440 /etc/sudoers.d/"${USER}" && \
    passwd -d "${USER}" && \
    mkdir $HOME/scripts

USER "${USER}"

# copy scripts to container
COPY scripts-utils.zip $HOME
RUN sudo chown -R ${USER} $HOME/scripts && \
    sudo unzip $HOME/scripts-utils.zip -d $HOME/scripts/utils && \
    rm $HOME/scripts-utils.zip
COPY scripts/run-with-utils.sh $HOME/scripts
COPY scripts/unpack-and-install.sh $HOME/scripts

# Install all plugins
# The order is:
#   [core] -> [common] -> [app] -> [custom] -> [dev]

# Variables to config core plugins.
# These variables will be read by setup scripts.
ARG LOCALE="C.UTF-8"
ARG TZ="Asia/Tokyo"
ARG USE_SYSTEMD="yes"

# Install core plugins
COPY scripts-core.zip $HOME
RUN LOCALE=${LOCALE} \
    TZ=${TZ} \
    USE_SYSTEMD=${USE_SYSTEMD} \
    $HOME/scripts/unpack-and-install.sh core

# Variables to decide which package to be installed.
# These variables will be read by setup scripts.
ARG USE_SSH=no
ARG USE_VNC=no
ARG VNC_PSWD="vncpswd"
ARG USE_NO_VNC=no
ARG USE_OMZ=no
ARG USE_GUI=no

# Install common plugins
COPY scripts-common.zip $HOME
RUN USE_SYSTEMD=${USE_SYSTEMD} \
    USE_SSH=${USE_SSH} \
    USE_VNC=${USE_VNC} \
    VNC_PSWD=${VNC_PSWD} \
    USE_NO_VNC=${USE_NO_VNC} \
    USE_OMZ=${USE_OMZ} \
    USE_GUI=${USE_GUI} \
    $HOME/scripts/unpack-and-install.sh common

# Install app plugins, always copy the file into the image
# and remove them regardless of installing them or not
ARG USE_APP=no
COPY scripts-app.zip $HOME
RUN ([ "${USE_APP}" = "yes" ] && \
    $HOME/scripts/unpack-and-install.sh app) || \
    rm $HOME/scripts-app.zip

# Install custom plugins
COPY scripts-custom.zip $HOME
RUN $HOME/scripts/unpack-and-install.sh custom

# Install dev plugins
COPY scripts-dev.zip $HOME
RUN $HOME/scripts/unpack-and-install.sh dev

# set user password
ARG USER_PSWD="CHANGE_ME"
ARG USE_USER_PSWD="no"
RUN ([ $USE_USER_PSWD = yes ] && \
    echo "${USER}:${USER_PSWD}" | sudo chpasswd) || true

# Switch back to root to start systemd (in case that USE_SYSTEMD is set)
USER root

# Remove unnecessary system targets
# TODO remove more targets but make sure that startup completes and login promt is displayed when "docker run -it"
#   https://github.com/moby/moby/issues/42275#issue-853601974
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* \
    /lib/systemd/system/systemd-update-utmp* \
    /lib/systemd/system/systemd-resolved.service

CMD [ "/sbin/init" ]
