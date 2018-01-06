#!/bin/bash

# HELK script: helk_docker_entryppoint.sh
# HELK script description: Restart ELK services and runs Spark
# HELK build version: 0.9 (BETA)
# HELK ELK version: 6.x
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

# Start ELK services & Nginx
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

# Start Cron
service cron start

#creating kibana index
echo "[HELK-DOCKER-INSTALLATION-INFO] Running helk_kibana_setup.sh script..."
./helk_kibana_setup.sh

#Start Spark
/opt/helk/spark/spark-2.2.1-bin-hadoop2.7/bin/pyspark