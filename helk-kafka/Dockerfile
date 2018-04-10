# HELK script: HELK Kafka Dockerfile
# HELK build version: 0.9 (Alpha)
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

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
ENV KAFKA_HOME=/opt/helk/kafka/kafka_2.11-${KAFKA_VERSION}

RUN wget -qO- http://mirrors.ocf.berkeley.edu/apache/kafka/1.1.0/kafka_2.11-${KAFKA_VERSION}.tgz | sudo tar xvz -C /opt/helk/kafka/ \
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