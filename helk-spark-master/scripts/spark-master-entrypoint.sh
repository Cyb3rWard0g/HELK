#!/bin/sh

# HELK script: spark-master-entrypoint.sh
# HELK script description: Starts Spark Master Service
# HELK build version: 0.9 (Alpha)
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

ln -sf /dev/stdout $SPARK_MASTER_LOG/spark-master.out

echo "[HELK-DOCKER-INSTALLATION-INFO] Starting Spark Master Service.."
exec $SPARK_HOME/bin/spark-class org.apache.spark.deploy.master.Master \
    --host $SPARK_MASTER_HOST --port $SPARK_MASTER_PORT --webui-port $SPARK_MASTER_WEBUI_PORT >> $SPARK_MASTER_LOG/spark-master.out