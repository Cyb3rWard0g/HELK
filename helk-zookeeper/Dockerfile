# HELK script: HELK Kafka Zookeeper Dockerfile
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

FROM cyb3rward0g/helk-kafka-base:1.1.0
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for the HELK Kafka Zookeeper."

ENV DEBIAN_FRONTEND noninteractive

# *********** Creating the right directories ***************
RUN bash -c 'mkdir -pv /opt/helk/zookeeper'

# *********** Install Zookeeper ***************
ENV ZOO_CONF_DIR=/opt/helk/zookeeper/conf \
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
RUN mkdir -p "$ZOO_CONF_DIR" "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" "$ZOO_LOGS_PATH"
ADD scripts/zookeeper-entrypoint.sh /opt/helk/scripts/
RUN chmod +x /opt/helk/scripts/zookeeper-entrypoint.sh

VOLUME ["$ZOO_DATA_DIR", "$ZOO_DATA_LOG_DIR"]

EXPOSE $ZOO_PORT 2888 3888
WORKDIR "/opt/helk/scripts/"
ENTRYPOINT ["./zookeeper-entrypoint.sh"]