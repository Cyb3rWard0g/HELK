#!/bin/bash

# HELK script: kafka-entrypoint.sh
# HELK script description: Starts Kafka services
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# *********** Configuring Kafka **************
echo "[HELK-DOCKER-INSTALLATION-INFO] Setting current host IP to brokers server.properties files.."
if [[ ! -z "$KAFKA_BROKER_PORT" ]] && [[ ! -z "$KAFKA_BROKER_NAME" ]] && [[ ! -z "$KAFKA_BROKER_ID" ]]; then
  sed -i "s/advertised\.listeners\=PLAINTEXT:\/\/HELKIP\:9092/advertised\.listeners\=PLAINTEXT\:\/\/${ADVERTISED_LISTENER}\:${KAFKA_BROKER_PORT}/g" ${KAFKA_HOME}/config/server.properties
  sed -i "s/listeners\=PLAINTEXT:\/\/helk-kafka:9092/listeners\=PLAINTEXT:\/\/${KAFKA_BROKER_NAME}:${KAFKA_BROKER_PORT}/g" ${KAFKA_HOME}/config/server.properties
  sed -i "s/listeners\=PLAINTEXT:\/\/helk-kafka:9092/listeners=PLAINTEXT:\/\/${KAFKA_BROKER_NAME}\:${KAFKA_BROKER_PORT}/g" ${KAFKA_HOME}/config/server.properties
  sed -i "s/broker\.id\=0/broker.id=${KAFKA_BROKER_ID}/g" ${KAFKA_HOME}/config/server.properties
else
  echo "[ERROR] Make sure you define the BROKERS NAME, PORT & ID environment variables"
  exit 1
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

# *********** Starting Kafka **************
exec $KAFKA_SCRIPT $KAFKA_CONFIG >> $KAFKA_CONSOLE_LOG 2>&1 &
sleep 20

# *********** Creating Kafka Topics**************
declare -a temas=("winlogbeat" "sysmontransformed" "securitytransformed")

for t in ${temas[@]}; do 
  echo "[HELK-DOCKER-INSTALLATION-INFO] Creating Kafka ${t} Topic.."
  ${KAFKA_HOME}/bin/kafka-topics.sh --create --zookeeper ${ZOOKEEPER_NAME}:2181 --replication-factor ${REPLICATION_FACTOR} --partitions 1 --topic ${t} --if-not-exists
done

tail -f $KAFKA_CONSOLE_LOG
