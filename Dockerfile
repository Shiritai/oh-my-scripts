FROM ubuntu:latest

ARG USERNAME="user"
ARG TZ="Asia/Taipei"
ENV USER "${USERNAME}"
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE DontWarn

RUN echo ${USERNAME} && \
    ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone && \
    apt update && apt upgrade -y && \
    apt install sudo unzip -y && \
    useradd -m -G sudo "${USERNAME}" && \
    echo "${USERNAME} ALL = NOPASSWD: ALL" > /etc/sudoers.d/"${USERNAME}" && \
    chmod 0440 /etc/sudoers.d/"${USERNAME}" && \
    passwd -d "${USERNAME}" && \
    mkdir /home/${USERNAME}/data

USER "${USERNAME}"

COPY scripts.zip /home/${USERNAME}
RUN sudo unzip /home/${USERNAME}/scripts.zip -d /home/${USERNAME}
RUN /home/${USERNAME}/scripts/setup.sh && \
    rm /home/${USERNAME}/scripts.zip

WORKDIR /home/${USERNAME}

CMD [ "bash" ]