# HELK script: HELK Kafka Dockerfile
# HELK build version: 0.9 (Alpha)
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

FROM phusion/baseimage
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for the HELK Kafka."

USER root

ENV DEBIAN_FRONTEND noninteractive

# *********** Installing Prerequisites ***************
# -qq : No output except for errors
RUN echo "[HELK-DOCKER-INSTALLATION-INFO] Updating Ubuntu base image.." \
  && apt-get update -qq \
  && echo "[HELK-DOCKER-INSTALLATION-INFO] Extracting templates from packages.." \
  && apt-get install -qqy \
  openjdk-8-jre-headless \
  wget \
  sudo \
  nano
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen
RUN apt-get -qy clean \
  autoremove \
  && rm -rf /var/lib/apt/lists/*

# *********** Creating the right directories ***************
RUN bash -c 'mkdir -pv /opt/helk/{scripts,kafka}'
 
# *********** Install Kafka ***************
ENV KAFKA_LOGS_PATH=/var/log/kafka
ENV KAFKA_HOME=/opt/helk/kafka/kafka_2.11-1.0.1

RUN wget -qO- http://mirrors.advancedhosters.com/apache/kafka/1.0.1/kafka_2.11-1.0.1.tgz | sudo tar xvz -C /opt/helk/kafka/ \
  && mkdir -v $KAFKA_LOGS_PATH \
  && mv ${KAFKA_HOME}/config/server.properties ${KAFKA_HOME}/config/backup_server.properties
ADD *.properties ${KAFKA_HOME}/config/
ADD kafka-init /etc/init.d/kafka
ADD scripts/kafka-entrypoint.sh /opt/helk/scripts/
RUN chmod +x /opt/helk/scripts/kafka-entrypoint.sh

# *********** Download KSQL ******************************
ENV KSQL_VERSION=0.4
RUN wget -qO- https://github.com/confluentinc/ksql/releases/download/v${KSQL_VERSION}/ksql-${KSQL_VERSION}.tgz | sudo tar xvz -C /opt/helk/

EXPOSE 2181 9092 9093 9094
WORKDIR "/opt/helk/scripts/"
ENTRYPOINT ["./kafka-entrypoint.sh"]