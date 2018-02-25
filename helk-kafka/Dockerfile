# HELK script: HELK Kafka Dockerfile
# HELK build version: 0.9 (Alpha)
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

FROM phusion/baseimage
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for the HELK Kafka."

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
RUN wget -qO- http://apache.mirrors.lucidnetworks.net/kafka/1.0.0/kafka_2.11-1.0.0.tgz | sudo tar xvz -C /opt/helk/kafka/ \
  && mkdir -v $KAFKA_LOGS_PATH \
  && mv /opt/helk/kafka/kafka_2.11-1.0.0/config/server.properties /opt/helk/kafka/kafka_2.11-1.0.0/config/backup_server.properties
ADD *.properties /opt/helk/kafka/kafka_2.11-1.0.0/config/
ADD kafka-init /etc/init.d/kafka
ADD scripts/kafka-entrypoint.sh /opt/helk/scripts/
RUN chmod +x /opt/helk/scripts/kafka-entrypoint.sh

EXPOSE 2181 9092 9093 9094
WORKDIR "/opt/helk/scripts/"
ENTRYPOINT ["./kafka-entrypoint.sh"]