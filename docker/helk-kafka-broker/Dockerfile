# HELK script: HELK Kafka Broker Dockerfile
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

FROM otrf/helk-kafka-base:2.4.0
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for the HELK Kafka Broker."

ENV DEBIAN_FRONTEND noninteractive

# *********** Configure Kafka Broker ***************
ENV KAFKA_SCRIPT=$KAFKA_HOME/bin/kafka-server-start.sh
ENV KAFKA_CONFIG=$KAFKA_HOME/config/server.properties

RUN mv $KAFKA_CONFIG ${KAFKA_HOME}/config/backup_server.properties
COPY server.properties ${KAFKA_HOME}/config/
COPY scripts ${KAFKA_HOME}/scripts
RUN chmod +x ${KAFKA_HOME}/scripts/kafka-entrypoint.sh \
    && chmod +x ${KAFKA_HOME}/scripts/kafka-create-topics.sh

USER ${KAFKA_USER}

WORKDIR /opt/helk/kafka/scripts/
ENTRYPOINT ["./kafka-entrypoint.sh"]
CMD ["/bin/bash","-c","$KAFKA_SCRIPT $KAFKA_CONFIG"]