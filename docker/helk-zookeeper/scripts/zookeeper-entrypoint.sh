#!/bin/sh

# HELK script: zookeeper-entrypoint.sh
# HELK script description: Starts Kafka Zookeeper services
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# Generate the config only if it doesn't exist
if [ ! -f $ZOO_CONF_DIR/zookeeper.properties ]; then
    CONFIG=$ZOO_CONF_DIR/zookeeper.properties

    echo "clientPort=$ZOO_PORT" >> "$CONFIG"
    echo "dataDir=$ZOO_DATA_DIR" >> "$CONFIG"
    echo "dataLogDir=$ZOO_DATA_LOG_DIR" >> "$CONFIG"

    echo "tickTime=$ZOO_TICK_TIME" >> "$CONFIG"
    echo "initLimit=$ZOO_INIT_LIMIT" >> "$CONFIG"
    echo "syncLimit=$ZOO_SYNC_LIMIT" >> "$CONFIG"

    echo "maxClientCnxns=$ZOO_MAX_CLIENT_CNXNS" >> "$CONFIG"

    for server in $ZOO_SERVERS; do
        echo "$server" >> "$CONFIG"
    done
fi

ln -sf /dev/stdout $ZOO_LOGS_FILE

echo "[HELK-DOCKER-INSTALLATION-INFO] Starting Zookeeper.."
KAFKA_SCRIPT_ZOOKEEPER=$KAFKA_HOME/bin/zookeeper-server-start.sh
KAFKA_CONFIG_ZOOKEEPER="$ZOO_CONF_DIR/zookeeper.properties"

exec $KAFKA_SCRIPT_ZOOKEEPER $KAFKA_CONFIG_ZOOKEEPER >> $ZOO_LOGS_FILE 2>&1
