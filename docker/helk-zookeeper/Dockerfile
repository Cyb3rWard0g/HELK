# HELK script: HELK Kafka Zookeeper Dockerfile
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

FROM otrf/helk-kafka-base:2.4.0
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for the HELK Kafka Zookeeper."

ENV DEBIAN_FRONTEND noninteractive

# *********** ConfigureZookeeper ***************
ENV ZOO_HOME=/opt/helk/zookeeper \
    ZOO_CONF_DIR=/opt/helk/zookeeper/conf \
    ZOO_DATA_DIR=/opt/helk/zookeeper/data \
    ZOO_DATA_LOG_DIR=/opt/helk/zookeeper/datalog \
    ZOO_PORT=2181 \
    ZOO_TICK_TIME=2000 \
    ZOO_INIT_LIMIT=20 \
    ZOO_SYNC_LIMIT=2 \
    ZOO_MAX_CLIENT_CNXNS=60 \
    ZOO_LOGS_PATH=/var/log/zookeeper \
    ZOO_LOGS_FILE=${ZOO_LOGS_PATH}/zookeeper.log

# *********** Configure zookeeper ***************
RUN bash -c 'mkdir -pv /opt/helk/zookeeper'
COPY scripts /opt/helk/zookeeper/scripts
RUN mkdir -p "$ZOO_CONF_DIR" "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" "$ZOO_LOGS_PATH" \
    && chmod +x /opt/helk/zookeeper/scripts/zookeeper-entrypoint.sh \
    && chown -R ${KAFKA_USER}:${KAFKA_USER} ${ZOO_HOME} ${ZOO_LOGS_PATH}

USER ${KAFKA_USER}

EXPOSE 2181 2888 3888
WORKDIR "/opt/helk/zookeeper/scripts/"
ENTRYPOINT ["./zookeeper-entrypoint.sh"]
CMD ["/bin/bash","-c","/opt/helk/kafka/bin/zookeeper-server-start.sh /opt/helk/zookeeper/conf/zookeeper.properties"]