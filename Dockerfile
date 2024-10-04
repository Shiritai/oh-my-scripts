ARG BASE_IMG="ubuntu:20.04"
FROM ${BASE_IMG}

ENV container=docker
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE DontWarn
ENV DEBIAN_FRONTEND noninteractive

ARG LOCALE="C.UTF-8"
ARG TZ="Asia/Tokyo"

# Set locale and timezone
RUN echo -e "[\e[1;34mINFO\e[0m] Setup locale to ${LOCALE} and timezone to ${TZ}" && \
    apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends locales > /dev/null && \
    echo "$LOCALE UTF-8" >> /etc/locale.gen && \
    locale-gen && \
    ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo ${TZ} > /etc/timezone && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install systemd
ARG USE_SYSTEMD="yes"
RUN ([ ${USE_SYSTEMD} = yes ] && \
    echo -e "[\e[1;34mINFO\e[0m] Use systemd" && \
    apt-get update -qq -y && \
    apt-get install -qq -y dbus dbus-x11 systemd > /dev/null) || true

# Setup user, after sudo user created and set,
# the commands that needs root priviledge needs "sudo"
ARG USER="user"
ENV USER "${USER}"
RUN echo -e "[\e[1;34mINFO\e[0m] Setup user $USER" && \
    apt-get update -qq -y && \
    apt-get upgrade -qq -y && \
    apt-get install -qq -y sudo unzip && \
    useradd -m -G sudo "${USER}" && \
    echo "${USER} ALL = NOPASSWD: ALL" > /etc/sudoers.d/"${USER}" && \
    chmod 0440 /etc/sudoers.d/"${USER}" && \
    passwd -d "${USER}" && \
    mkdir /home/${USER}/scripts

USER "${USER}"

# copy scripts to container
COPY scripts-utils.zip /home/${USER}
RUN sudo chown -R ${USER} /home/${USER}/scripts && \
    sudo unzip /home/${USER}/scripts-utils.zip -d /home/${USER} && \
    rm /home/${USER}/scripts-utils.zip
COPY scripts/run-with-utils.sh /home/${USER}/scripts

# Environment variables to decide which package to be installed.
# These environment variable will be read by setup scripts.
ARG USE_SSH=no
ENV USE_SSH "${USE_SSH}"

ARG USE_VNC=no
ENV USE_VNC "${USE_VNC}"

ARG USE_NO_VNC=no
ENV USE_NO_VNC "${USE_NO_VNC}"

ARG VNC_PSWD="vncpswd"
ENV VNC_PSWD "${VNC_PSWD}"

ARG USE_OMZ=no
ENV USE_OMZ "${USE_OMZ}"

ARG USE_GUI=no
ENV USE_GUI "${USE_GUI}"

# Install common plugins
COPY scripts-common.zip /home/${USER}
RUN sudo chown -R ${USER} /home/${USER}/scripts && \
    sudo unzip /home/${USER}/scripts-common.zip -d /home/${USER} && \
    rm /home/${USER}/scripts-common.zip && \
    /home/${USER}/scripts/run-with-utils.sh \
    setup_all_plugins_in /home/${USER}/scripts/common

# Install app plugins, always copy zip file in
# and always remove them regardless of installing them or not
ARG USE_APP=no
COPY scripts-app.zip /home/${USER}
RUN ([ "${USE_APP}" = "yes" ] && \
    sudo chown -R ${USER} /home/${USER}/scripts && \
    sudo unzip /home/${USER}/scripts-app.zip -d /home/${USER} && \
    rm /home/${USER}/scripts-app.zip && \
    /home/${USER}/scripts/run-with-utils.sh \
    setup_all_plugins_in /home/${USER}/scripts/app) || \
    rm /home/${USER}/scripts-app.zip

# Install custom plugins
COPY scripts-custom.zip /home/${USER}
RUN sudo chown -R ${USER} /home/${USER}/scripts && \
    sudo unzip /home/${USER}/scripts-custom.zip -d /home/${USER} && \
    rm /home/${USER}/scripts-custom.zip && \
    /home/${USER}/scripts/run-with-utils.sh \
    setup_all_plugins_in /home/${USER}/scripts/custom

# Install dev plugins
COPY scripts-dev.zip /home/${USER}
RUN sudo chown -R ${USER} /home/${USER}/scripts && \
    sudo unzip /home/${USER}/scripts-dev.zip -d /home/${USER} && \
    rm /home/${USER}/scripts-dev.zip && \
    /home/${USER}/scripts/run-with-utils.sh \
    setup_all_plugins_in /home/${USER}/scripts/dev

# set user password
ARG USER_PSWD="CHANGE_ME"
ENV USER_PSWD "${USER_PSWD}"
RUN echo "${USER}:${USER_PSWD}" | sudo chpasswd

# Switch back to root to start systemd (when USE_SYSTEMD is set)
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
