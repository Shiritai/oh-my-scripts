ARG BASE_IMG="ubuntu:20.04"
FROM ${BASE_IMG}

ENV container=docker

ARG USE_SYSTEMD="yes"
ENV USE_SYSTEMD "${USE_SYSTEMD}"

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

# Set locale
ENV LANG=C.UTF-8
# ENV LC_ALL=C.UTF-8
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales && \
    echo "$LANG UTF-8" >> /etc/locale.gen && \
    locale-gen && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Unminimize to include man pages
RUN yes | unminimize

# Install systemd
RUN [ ${USE_SYSTEMD} = yes ] && \
    apt-get update -qq && apt-get install -qq -y \
    dbus dbus-x11 systemd && \
    dpkg-divert --local --rename --add /sbin/udevadm && \
    ln -s /bin/true /sbin/udevadm

# Setup user, after sudo user created and set,
# the commands that needs root priviledge needs "sudo"
RUN apt-get update -qq -y && apt-get upgrade -qq -y && \
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

# Install common plugins
COPY scripts-common.zip /home/${USER}
RUN sudo chown -R ${USER} /home/${USER}/scripts && \
    sudo unzip /home/${USER}/scripts-common.zip -d /home/${USER} && \
    rm /home/${USER}/scripts-common.zip && \
    /home/${USER}/scripts/run-with-utils.sh \
    setup_all_plugins_in /home/${USER}/scripts/common

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

WORKDIR /home/${USER}

# set user password
RUN echo "${USER}:${USER_PSWD}" | sudo chpasswd

# Switch back to root to start systemd
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
