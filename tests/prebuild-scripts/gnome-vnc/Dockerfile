ARG BASE_IMG="ubuntu:20.04"
FROM ${BASE_IMG}

ENV container=docker
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq -y && \
    apt-get install -qq -y \
        gnome-session \
        gnome-terminal \
        gnome-control-center \
        nautilus \
        tigervnc-common \
        tigervnc-scraping-server \
        tigervnc-standalone-server \
        tigervnc-viewer \
        tigervnc-xorg-extension

RUN apt-get clean && \
        rm -rf /var/lib/apt/lists/*
