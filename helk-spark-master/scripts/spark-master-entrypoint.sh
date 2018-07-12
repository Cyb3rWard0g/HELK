#!/bin/sh

# HELK script: spark-master-entrypoint.sh
# HELK script description: Starts Spark Master Service
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

ln -sf /dev/stdout $SPARK_LOGS/spark-master.out

echo "[HELK-DOCKER-INSTALLATION-INFO] Starting Spark Master Service.."
exec $SPARK_HOME/bin/spark-class org.apache.spark.deploy.master.Master \
    --host $SPARK_MASTER_HOST --port $SPARK_MASTER_PORT --webui-port $SPARK_MASTER_WEBUI_PORT >> $SPARK_LOGS/spark-master.out