#!/bin/bash

# HELK script: elasticsearch-entrypoint.sh
# HELK script description: sets elasticsearch configs and starts elasticsearch
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# *********** Looking for ES ***************
if [[ -z "$ES_JAVA_OPTS" ]]; then
    ES_MEMORY=$(awk '/MemAvailable/{printf "%.f", $2/1024/1024/2}' /proc/meminfo)
    if [ $ES_MEMORY -gt 31 ]; then
      ES_MEMORY=31
    fi
    export ES_JAVA_OPTS="-Xms${ES_MEMORY}g -Xmx${ES_MEMORY}g"
fi
echo "[HELK-ES-DOCKER-INSTALLATION-INFO] Setting ES_JAVA_OPTS to $ES_JAVA_OPTS"

# *********** HELK ES Password ***************
if [[ -z "$ELASTIC_PASSWORD" ]]; then
  export ELASTIC_PASSWORD=elasticpassword
fi
echo "[HELK-ES-DOCKER-INSTALLATION-INFO] Setting Elastic password to $ELASTIC_PASSWORD"

# ********** Starting Elasticsearch *****************
echo "[HELK-ES-DOCKER-INSTALLATION-INFO] Running docker-entrypoint script.."
/usr/local/bin/docker-entrypoint.sh