# HELK script: HELK Kafka Base Dockerfile
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

FROM cyb3rward0g/helk-base:0.0.1
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for the HELK Kafka."

ENV DEBIAN_FRONTEND noninteractive

# *********** Installing Prerequisites ***************
# -qq : No output except for errors
RUN echo "[HELK-DOCKER-INSTALLATION-INFO] Updating Ubuntu base image.." \
  && apt-get update -qq \
  && echo "[HELK-DOCKER-INSTALLATION-INFO] Extracting templates from packages.." \
  && apt-get install -qqy \
  openjdk-8-jre-headless

RUN apt-get -qy clean \
  autoremove

# *********** Creating the right directories ***************
RUN bash -c 'mkdir -pv /opt/helk/kafka'
 
# *********** Install Kafka ***************
ENV KAFKA_VERSION=1.1.0
ENV KAFKA_LOGS_PATH=/var/log/kafka
ENV KAFKA_CONSOLE_LOG=/var/log/kafka/helk-kafka.log
ENV KAFKA_HOME=/opt/helk/kafka/kafka_2.11-${KAFKA_VERSION}

RUN wget -qO- http://mirrors.ocf.berkeley.edu/apache/kafka/1.1.0/kafka_2.11-${KAFKA_VERSION}.tgz | sudo tar xvz -C /opt/helk/kafka/ \
  && mkdir -v $KAFKA_LOGS_PATH