#!/bin/bash

# HELK script: helk_docker_entryppoint.sh
# HELK script description: Restart ELK services and runs Spark
# HELK build version: 0.9 (Alpha)
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

# Start graceful termination of HELK services that might be running before running the entrypoint script.
_term() {
  echo "Terminating HELK Services"
  service elasticsearch stop
  service logstash stop
  service kibana stop
  service cerebro stop
  service spark stop
  service kafka stop
  exit 0
}
trap _term SIGTERM

# Removing PID files just in case the graceful termination fails
rm -f /var/run/elasticsearch/elasticsearch.pid \
    /var/run/logstash.pid \
    /var/run/kibana.pid \
    /var/run/spark.pid \
    /var/run/cerebro.pid \
    /var/run/kafka_zookeeper.pid \
    /var/run/kafka.pid \
    /var/run/kafka_1.pid \
    /var/run/kafka_2.pid

# *********** Setting ES Heap Size***************
# https://serverfault.com/questions/881383/automatically-set-java-heap-size-for-elasticsearch-on-linux
memoryInKb="$(awk '/MemTotal/ {print $2}' /proc/meminfo)"
heapSize="$(expr $memoryInKb / 1024 / 1000 / 2)"
sed -i "s/#*-Xmx[0-9]\+g/-Xmx${heapSize}g/g" /etc/elasticsearch/jvm.options
sed -i "s/#*-Xms[0-9]\+g/-Xms${heapSize}g/g" /etc/elasticsearch/jvm.options

# *********** Setting Logstash Heap Size***************
# https://www.elastic.co/guide/en/logstash/current/performance-troubleshooting.html
sed -i "s/#*-Xmx[0-9]\+g/-Xmx2g/g" /etc/logstash/jvm.options
sed -i "s/#*-Xms[0-9]\+g/-Xms2g/g" /etc/logstash/jvm.options

# *********** Start HELK services ***************
echo "[HELK-DOCKER-INSTALLATION-INFO] Starting elasticsearch service"
service elasticsearch start
echo "[HELK-DOCKER-INSTALLATION-INFO] Waiting for elasticsearch URI to be accessible.."
until curl -s localhost:9200 -o /dev/null; do
    sleep 1
done

echo "[HELK-DOCKER-INSTALLATION-INFO] Starting remaining services.."
service kibana start
service nginx restart
service logstash start
service cerebro start
service spark start
service cron start

    # *********** Creating Kibana Dashboards, visualizations and index-patterns ***************
echo "[HELK-DOCKER-INSTALLATION-INFO] Running helk_kibana_setup.sh script..."
./helk_kibana_setup.sh

    # *********** Start Kafka **************
echo "[HELK-DOCKER-INSTALLATION-INFO] Setting current host IP to brokers server.properties files.."
sed -i "s/advertised\.listeners\=PLAINTEXT:\/\/HELKIP\:9092/advertised\.listeners\=PLAINTEXT\:\/\/${ADVERTISED_LISTENER}\:9092/g" /opt/helk/kafka/kafka_2.11-1.0.0/config/server.properties
sed -i "s/advertised\.listeners\=PLAINTEXT:\/\/HELKIP\:9093/advertised\.listeners\=PLAINTEXT\:\/\/${ADVERTISED_LISTENER}\:9093/g" /opt/helk/kafka/kafka_2.11-1.0.0/config/server-1.properties
sed -i "s/advertised\.listeners\=PLAINTEXT:\/\/HELKIP\:9094/advertised\.listeners\=PLAINTEXT\:\/\/${ADVERTISED_LISTENER}\:9094/g" /opt/helk/kafka/kafka_2.11-1.0.0/config/server-2.properties
echo "[HELK-DOCKER-INSTALLATION-INFO] Starting Kafka.."
service kafka start
sleep 20
echo "[HELK-DOCKER-INSTALLATION-INFO] Creating Kafka Winlogbeat Topic.."
/opt/helk/kafka/kafka_2.11-1.0.0/bin/kafka-topics.sh --create --zookeeper $ADVERTISED_LISTENER:2181 --replication-factor 3 --partitions 1 --topic winlogbeat

echo "[HELK-DOCKER-INSTALLATION-INFO] Pushing Spark Logs to console.."
tail -f /var/log/spark/spark_pyspark.log