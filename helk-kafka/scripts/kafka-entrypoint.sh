#!/bin/sh

# HELK script: kafka-entrypoint.sh
# HELK script description: Restarts and runs Kafka services
# HELK build version: 0.9 (Alpha)
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

# Start graceful termination of HELK services that might be running before running the entrypoint script.
_term() {
  echo "Terminating HELK-Kafka Service"
  service kafka stop
  exit 0
}
trap _term SIGTERM

# Removing PID files just in case the graceful termination fails
rm -f /var/run/kafka_zookeeper.pid \
    /var/run/kafka.pid \
    /var/run/kafka_1.pid \
    /var/run/kafka_2.pid

   # *********** Start Kafka **************
echo "[HELK-DOCKER-INSTALLATION-INFO] Setting current host IP to brokers server.properties files.."
sed -i "s/advertised\.listeners\=PLAINTEXT:\/\/HELKIP\:9092/advertised\.listeners\=PLAINTEXT\:\/\/${ADVERTISED_LISTENER}\:9092/g" /opt/helk/kafka/kafka_2.11-1.0.0/config/server.properties
sed -i "s/advertised\.listeners\=PLAINTEXT:\/\/HELKIP\:9093/advertised\.listeners\=PLAINTEXT\:\/\/${ADVERTISED_LISTENER}\:9093/g" /opt/helk/kafka/kafka_2.11-1.0.0/config/server-1.properties
sed -i "s/advertised\.listeners\=PLAINTEXT:\/\/HELKIP\:9094/advertised\.listeners\=PLAINTEXT\:\/\/${ADVERTISED_LISTENER}\:9094/g" /opt/helk/kafka/kafka_2.11-1.0.0/config/server-2.properties
echo "[HELK-DOCKER-INSTALLATION-INFO] Starting Kafka.."
service kafka start
sleep 30
echo "[HELK-DOCKER-INSTALLATION-INFO] Creating Kafka Winlogbeat Topic.."
/opt/helk/kafka/kafka_2.11-1.0.0/bin/kafka-topics.sh --create --zookeeper $ADVERTISED_LISTENER:2181 --replication-factor 3 --partitions 1 --topic winlogbeat

echo "[HELK-DOCKER-INSTALLATION-INFO] Pushing Spark Logs to console.."
tail -f /var/log/kafka/helk-*.log