#!/bin/bash

# HELK script: elasticsearch-entrypoint.sh
# HELK script description: sets elasticsearch configs and starts elasticsearch
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# *********** Setting ES_JAVA_OPTS ***************
if [[ -z "$ES_JAVA_OPTS" ]]; then
    if (grep -P "^#\-Xms\d+" "./config/jvm.options") && (grep -P "^#\-Xmx\d+" "./config/jvm.options"); then
        # Check using more accurate MB
        AVAILABLE_MEMORY=$(awk '/MemAvailable/{printf "%.f", $2/1024}' /proc/meminfo)
        if [ $AVAILABLE_MEMORY -ge 1000 -a $AVAILABLE_MEMORY -le 5999 ]; then
          ES_MEMORY="2000m"
        elif [ $AVAILABLE_MEMORY -ge 6000 -a $AVAILABLE_MEMORY -le 8999 ]; then
          ES_MEMORY="3200m"
        elif [ $AVAILABLE_MEMORY -ge 9000 -a $AVAILABLE_MEMORY -le 12999 ]; then
          ES_MEMORY="5000m"
        elif [ $AVAILABLE_MEMORY -ge 13000 -a $AVAILABLE_MEMORY -le 16000 ]; then
          ES_MEMORY="7100m"
        else
          # Using GB instead of MB -- because plenty of RAM now
          ES_MEMORY=$(( AVAILABLE_MEMORY / 1024 / 2 ))
          if [ $ES_MEMORY -gt 31 ]; then
            ES_MEMORY="31g"
          else
            ES_MEMORY="${ES_MEMORY}g"
          fi
        fi
        export ES_JAVA_OPTS="-Xms${ES_MEMORY} -Xmx${ES_MEMORY}"
        echo "[HELK-ES-DOCKER-INSTALLATION-INFO] Setting ES_JAVA_OPTS to $ES_JAVA_OPTS from custom HELK \"algorithm\""
    else
      echo "[HELK-ES-DOCKER-INSTALLATION-INFO] Setting ES_JAVA_OPTS to user defined (hardcoded) value from jvm.options"
    fi
else
  echo "[HELK-ES-DOCKER-INSTALLATION-INFO] Setting ES_JAVA_OPTS to $ES_JAVA_OPTS from runtime or docker config file "
fi


# ******** Checking License Type ***************
ENVIRONMENT_VARIABLES=$(env)
XPACK_LICENSE_TYPE="$(echo $ENVIRONMENT_VARIABLES | grep -oE 'xpack.license.self_generated.type=[^ ]*' | sed s/.*=//)"

# ******** Set Trial License Variables ***************
if [[ $XPACK_LICENSE_TYPE == "trial" ]]; then
  # *********** HELK ES Password ***************
  if [[ -z "$ELASTIC_PASSWORD" ]]; then
    export ELASTIC_PASSWORD=elasticpassword
  fi
  echo "[HELK-ES-DOCKER-INSTALLATION-INFO] Setting Elastic password to $ELASTIC_PASSWORD"
fi

echo "[HELK-ES-DOCKER-INSTALLATION-INFO] Setting Elastic license to $XPACK_LICENSE_TYPE"

# ********** Starting Elasticsearch *****************
echo "[HELK-ES-DOCKER-INSTALLATION-INFO] Running docker-entrypoint script.."
/usr/local/bin/docker-entrypoint.sh