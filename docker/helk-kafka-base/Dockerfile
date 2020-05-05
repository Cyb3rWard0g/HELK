# HELK script: HELK Kafka Base Dockerfile
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

FROM otrf/helk-base:0.0.4
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for the HELK Kafka."

ENV DEBIAN_FRONTEND noninteractive

# *********** Kafka Variables ***************
ENV KAFKA_VERSION=2.4.1
ENV SCALA_VERSION=2.13
ENV KAFKA_LOGS_PATH=/var/log/kafka
ENV KAFKA_CONSOLE_LOG=/var/log/kafka/helk-kafka.log
ENV KAFKA_HOME=/opt/helk/kafka
ENV KAFKA_GID=910
ENV KAFKA_UID=910
ENV KAFKA_USER=kafkauser

# *********** Installing Prerequisites ***************
# -qq : No output except for errors
RUN echo "[HELK-DOCKER-INSTALLATION-INFO] Updating Ubuntu base image.." \
  && apt-get update -qq \
  && echo "[HELK-DOCKER-INSTALLATION-INFO] Extracting templates from packages.." \
  && apt-get install -qqy \
  openjdk-8-jre-headless \
  && apt-get -qy clean \
  autoremove \
  && rm -rf /var/lib/apt/lists/* \
  # *********** Creating the right directories ***************
  && bash -c 'mkdir -pv /opt/helk/kafka' \
  # ********* Downloading Kafka *************
  && wget -qO- https://mirrors.ocf.berkeley.edu/apache/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz | sudo tar xvz -C /opt/helk/kafka/ --strip-components=1 \
  && mkdir -v $KAFKA_LOGS_PATH \
  # ********* Adding Kafka User *************
  && groupadd -g ${KAFKA_GID} ${KAFKA_USER} \
  && useradd -u ${KAFKA_UID} -g ${KAFKA_GID} -d ${KAFKA_HOME} --no-create-home -s /bin/bash ${KAFKA_USER} \
  && chown -R ${KAFKA_USER}:${KAFKA_USER} ${KAFKA_HOME} ${KAFKA_LOGS_PATH}