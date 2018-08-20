#!/bin/bash

# HELK script: elasticsearch-entrypoint.sh
# HELK script description: sets elasticsearch configs and starts elasticsearch
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# *********** Looking for ES ***************
if [[ ! -z "$ES_JAVA_OPTS" ]]; then
  echo "[HELK-DOCKER-INSTALLATION-INFO] Setting ES_JAVA_OPTS to $ES_JAVA_OPTS"
else
  # ****** Setup heap size and memory locking *****
    ES_MEMORY=$(awk '/MemAvailable/{printf "%.f", $2/1024/1024/2}' /proc/meminfo)
    echo "[HELK-DOCKER-INSTALLATION-INFO] Setting ES_HEAP_SIZE to ${ES_MEMORY}.."
    export ES_JAVA_OPTS="-Xms${ES_MEMORY}g -Xmx${ES_MEMORY}g"
fi

# ********** Starting Elasticsearch *****************
echo "[HELK-DOCKER-INSTALLATION-INFO] Running docker-entrypoint script.."
/usr/local/bin/docker-entrypoint.sh