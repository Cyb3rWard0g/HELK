#!/bin/sh

# HELK script: spark-worker-entrypoint.sh
# HELK script description: Starts Spark Worker Service
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

ln -sf /dev/stdout $SPARK_LOGS/spark-worker.out

echo "[HELK-DOCKER-INSTALLATION-INFO] Starting Spark Worker Service.."
exec /$SPARK_HOME/bin/spark-class org.apache.spark.deploy.worker.Worker \
    --webui-port $SPARK_WORKER_WEBUI_PORT $SPARK_MASTER >> $SPARK_LOGS/spark-worker.out