#!/bin/bash

# HELK script: spark-worker-entrypoint.sh
# HELK script description: Starts Spark Worker Service
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0
# Reference:
# https://github.com/apache/spark/blob/master/sbin/start-slave.sh (Modified to not execute daemon script)

if [ -z "${SPARK_HOME}" ]; then
  export SPARK_HOME="$(cd "`dirname "$0"`"/..; pwd)"
fi

# NOTE: This exact class name is matched downstream by SparkSubmit.
# Any changes need to be reflected there.
CLASS="org.apache.spark.deploy.worker.Worker"

#if [[ $# -lt 1 ]] || [[ "$@" = *--help ]] || [[ "$@" = *-h ]]; then
if [[ "$@" = *--help ]] || [[ "$@" = *-h ]]; then
  echo "Usage: ./sbin/start-slave.sh [options] <master>"
  pattern="Usage:"
  pattern+="\|Using Spark's default log4j profile:"
  pattern+="\|Registered signal handlers for"

  "${SPARK_HOME}"/bin/spark-class $CLASS --help 2>&1 | grep -v "$pattern" 1>&2
  exit 1
fi

. "${SPARK_HOME}/sbin/spark-config.sh"

. "${SPARK_HOME}/bin/load-spark-env.sh"

# First argument should be the master; we need to store it aside because we may
# need to insert arguments between it and the other arguments
#MASTER=$1
#shift

# ****** SETTINGS ******
# SPARM MASTER
if [ -z "$SPARK_MASTER" ]; then
  SPARK_MASTER=spark://localhost:7077
fi
echo "[+] Setting SPARK_MASTER to $SPARK_MASTER"

# SPARK_WORKER_MEMORY
if [ -z "$SPARK_WORKER_MEMORY" ]; then
  SPARK_WORKER_MEMORY=512M
fi
echo "[+] Setting SPARK_WORKER_MEMORY to $SPARK_WORKER_MEMORY"

# SPARK_WORKER_WEBUI_PORT
if [  -z "$SPARK_WORKER_WEBUI_PORT" ]; then
  SPARK_WORKER_WEBUI_PORT=8081
fi
echo "[+] Setting SPARK_WORKER_WEBUI_PORT to $SPARK_WORKER_WEBUI_PORT"

# SPARK_WORKER_PORT
if [  -z "$SPARK_WORKER_PORT" ]; then
  PORT_FLAG=
  PORT_NUM=
else
  PORT_FLAG="--port"
  PORT_NUM="$SPARK_WORKER_PORT"
  echo "[+] Setting SPARK_WORKER_WEBUI to $SPARK_WORKER_PORT"
fi

# ***** STARTING WORKER *****
$SPARK_HOME/bin/spark-class $CLASS \
  --webui-port $SPARK_WORKER_WEBUI_PORT $PORT_FLAG $PORT_NUM $SPARK_MASTER --memory $SPARK_WORKER_MEMORY

# Start up the appropriate number of workers on this machine.
# quick local function to start a worker
#function start_instance {
#  WORKER_NUM=$1
#  shift

#  if [ "$SPARK_WORKER_PORT" = "" ]; then
#    PORT_FLAG=
#    PORT_NUM=
#  else
#    PORT_FLAG="--port"
#    PORT_NUM=$(( $SPARK_WORKER_PORT + $WORKER_NUM - 1 ))
#  fi
#  WEBUI_PORT=$(( $SPARK_WORKER_WEBUI_PORT + $WORKER_NUM - 1 ))

#  $SPARK_HOME/bin/spark-class $CLASS $WORKER_NUM \
#     --webui-port "$WEBUI_PORT" $PORT_FLAG $PORT_NUM $MASTER "$@"
#}

#if [ "$SPARK_WORKER_INSTANCES" = "" ]; then
#  start_instance 1 "$@"
#else
#  for ((i=0; i<$SPARK_WORKER_INSTANCES; i++)); do
#    start_instance $(( 1 + $i )) "$@"
#  done
#fi