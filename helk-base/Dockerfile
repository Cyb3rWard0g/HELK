# HELK script: HELK Base Image Dockerfile
# HELK build version: 0.9 (Alpha)
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

FROM phusion/baseimage:0.10.1
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile HELK Base Image.."

ENV DEBIAN_FRONTEND noninteractive

# *********** Installing Prerequisites ***************
# -qq : No output except for errors
RUN echo "[HELK-DOCKER-BASE-INFO] Updating Ubuntu base image.." \
  && apt-get update -qq \
  && echo "[HELK-DOCKER-BASE-INFO] Extracting templates from packages.." \
  && apt-get install -qqy \
  wget \
  sudo \
  nano

RUN apt-get -qy clean \
  autoremove \
  && rm -rf /var/lib/apt/lists/*

# *********** Creating the right directories ***************
RUN bash -c 'mkdir -pv /opt/helk/scripts'

CMD ["/sbin/my_init"]