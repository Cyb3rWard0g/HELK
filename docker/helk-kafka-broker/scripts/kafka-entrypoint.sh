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

./kafka-create-topics.sh &
unset KAFKA_CREATE_TOPICS

exec "$@"
