#!/bin/bash

# HELK script: kafka-create-topics.sh
# HELK script description: creates kafka topics
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# *********** Configuring Kafka **************
if [[ -z "$KAFKA_CREATE_TOPICS" ]]; then
  echo "[HELK-DOCKER-INSTALLATION-INFO] No topics will be created"
  exit 0
fi

if [[ ! -z "$REPLICATION_FACTOR" ]]; then
  echo "[HELK-DOCKER-INSTALLATION-INFO] Setting replication factor for topics to $REPLICATION_FACTOR"
else
  REPLICATION_FACTOR=1
fi

if [[ ! -z "$ZOOKEEPER_NAME" ]]; then
  echo "[HELK-DOCKER-INSTALLATION-INFO] Setting Zookeeper name to $ZOOKEEPER_NAME"
else
  ZOOKEEPER_NAME=localhost
fi

# *********** Waiting for Kafka broker to be up ***************
echo "[HELK-DOCKER-INSTALLATION-INFO] Checking to see if Kafka broker is up..."
while [[ "$(curl -sm5 $KAFKA_BROKER_NAME:$KAFKA_BROKER_PORT -o /dev/null; echo $?)" != 56 ]] ; do
  echo "[HELK-DOCKER-INSTALLATION-INFO] Kafka broker $KAFKA_BROKER_NAME is not available yet"
  sleep 1
done

echo "[HELK-DOCKER-INSTALLATION-INFO] Kafka is up now..."
echo "[HELK-DOCKER-INSTALLATION-INFO] Giving kakfa some time to connect to Zookeeper..."
sleep 10

# *********** Creating Kafka Topics**************
declare -a temas=("winlogbeat" "sysmontransformed" "securitytransformed")

for t in ${temas[@]}; do 
  echo "[HELK-DOCKER-INSTALLATION-INFO] Creating Kafka ${t} Topic.."
  ${KAFKA_HOME}/bin/kafka-topics.sh --create --zookeeper ${ZOOKEEPER_NAME}:2181 --replication-factor ${REPLICATION_FACTOR} --partitions 1 --topic ${t} --if-not-exists
done

wait
