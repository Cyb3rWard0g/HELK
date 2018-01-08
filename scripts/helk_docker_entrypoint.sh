#!/bin/bash

# HELK script: helk_docker_entryppoint.sh
# HELK script description: Restart ELK services and runs Spark
# HELK build version: 0.9 (BETA)
# HELK ELK version: 6.x
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

# *********** Setting ES Heap Size***************
# https://serverfault.com/questions/881383/automatically-set-java-heap-size-for-elasticsearch-on-linux
memoryInKb="$(awk '/MemTotal/ {print $2}' /proc/meminfo)"
heapSize="$(expr $memoryInKb / 1024 / 1000 / 2)"
sed -i "s/#*-Xmx[0-9]\+g/-Xmx${heapSize}g/g" /etc/elasticsearch/jvm.options
sed -i "s/#*-Xms[0-9]\+g/-Xms${heapSize}g/g" /etc/elasticsearch/jvm.options

# *********** Start ELK services and Nginx ***************
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

# *********** Start Cron ***************
service cron start

# *********** Creating Kibana Dashboards, visualizations and index-patterns ***************
echo "[HELK-DOCKER-INSTALLATION-INFO] Running helk_kibana_setup.sh script..."
./helk_kibana_setup.sh

# *********** Start Spark ***************
/opt/helk/spark/spark-2.2.1-bin-hadoop2.7/bin/pyspark