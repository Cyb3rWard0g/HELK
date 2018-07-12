# HELK script: HELK Kafka Broker Dockerfile
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

FROM cyb3rward0g/helk-kafka-base:1.1.0
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for the HELK Kafka Broker."

ENV DEBIAN_FRONTEND noninteractive

ENV KAFKA_SCRIPT=$KAFKA_HOME/bin/kafka-server-start.sh
ENV KAFKA_CONFIG=$KAFKA_HOME/config/server.properties

# *********** Configure Kafka Broker ***************
RUN mv $KAFKA_CONFIG ${KAFKA_HOME}/config/backup_server.properties
ADD server.properties ${KAFKA_HOME}/config/
ADD scripts/kafka-entrypoint.sh /opt/helk/scripts/
RUN chmod +x /opt/helk/scripts/kafka-entrypoint.sh

EXPOSE $KAFKA_BROKER_PORT
WORKDIR "/opt/helk/scripts/"
ENTRYPOINT ["./kafka-entrypoint.sh"]