#!/bin/bash

# HELK script: elasticsearch-entrypoint.sh
# HELK script description: sets elasticsearch configs and starts elasticsearch
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# *********** Helk log tagging variables ***************
# For more efficient script editing/reading, and also if/when we switch to different install script language
HELK_INFO_TAG="[HELK-ELASTICSEARCH-DOCKER-INSTALLATION-INFO]"
HELK_ERROR_TAG="[HELK-ELASTICSEARCH-DOCKER-INSTALLATION-ERROR]"

# *********** Setting Elasticsearch Memory ***************
# Check to make sure not set in docker config/runtime
if [[ -z "$HELK_ES_MEMORY" ]]; then
  # Check to make sure not statically set in config file
  if (grep -P "^#\-Xms\d+" "./config/jvm.options") && (grep -P "^#\-Xmx\d+" "./config/jvm.options"); then
    # Check using more accurate MB
    AVAILABLE_MEMORY=$(awk '/MemAvailable/{printf "%.f", $2/1024}' /proc/meminfo)
    if [[ ${AVAILABLE_MEMORY} -le 899 ]]; then
      echo "$HELK_ERROR_TAG not enough memory!"
      exit 1
    elif [[ ${AVAILABLE_MEMORY} -ge 900 && ${AVAILABLE_MEMORY} -le 1299 ]]; then
      ES_MEMORY="600m"
    elif [[ ${AVAILABLE_MEMORY} -ge 1300 && ${AVAILABLE_MEMORY} -le 1999 ]]; then
      ES_MEMORY="1000m"
    elif [[ ${AVAILABLE_MEMORY} -ge 2000 && ${AVAILABLE_MEMORY} -le 2999 ]]; then
      ES_MEMORY="1000m"
    elif [[ ${AVAILABLE_MEMORY} -ge 3000 && ${AVAILABLE_MEMORY} -le 3999 ]]; then
      ES_MEMORY="2250m"
    elif [[ ${AVAILABLE_MEMORY} -ge 4000 && ${AVAILABLE_MEMORY} -le 4999 ]]; then
      ES_MEMORY="3200m"
    elif [[ ${AVAILABLE_MEMORY} -ge 6000 && ${AVAILABLE_MEMORY} -le 8999 ]]; then
      ES_MEMORY="4000m"
    elif [[ ${AVAILABLE_MEMORY} -ge 9000 && ${AVAILABLE_MEMORY} -le 12999 ]]; then
      ES_MEMORY="7000m"
    elif [[ ${AVAILABLE_MEMORY} -ge 13000 && ${AVAILABLE_MEMORY} -le 15999 ]]; then
      ES_MEMORY="10100m"
    else
      # Using GB instead of MB -- because plenty of RAM now
      ES_MEMORY=$(( AVAILABLE_MEMORY / 1024 / 2 ))
      if [[ ${ES_MEMORY} -gt 31 ]]; then
        ES_MEMORY="31g"
      else
        ES_MEMORY="${ES_MEMORY}g"
      fi
    fi
    export ES_JAVA_OPTS="${ES_JAVA_OPTS} -Xms${ES_MEMORY} -Xmx${ES_MEMORY} "
    echo "$HELK_INFO_TAG Setting ES_JAVA_OPTS to $ES_JAVA_OPTS from custom HELK \"algorithm\""
  else
    echo "$HELK_INFO_TAG Setting ES_JAVA_OPTS to user defined (hardcoded) value from jvm.options"
  fi
else
  echo "$HELK_INFO_TAG Setting ES_JAVA_OPTS to $ES_JAVA_OPTS from runtime docker config file"
fi


# ******** Checking License Type ***************
ENVIRONMENT_VARIABLES=$(env)
XPACK_LICENSE_TYPE="$(echo ${ENVIRONMENT_VARIABLES} | grep -oE 'xpack.license.self_generated.type=[^ ]*' | sed s/.*=//)"

# ******** Set Trial License Variables ***************
if [[ ${XPACK_LICENSE_TYPE} == "trial" ]]; then
  # *********** HELK ES Password ***************
  if [[ -z "$ELASTIC_PASSWORD" ]]; then
    export ELASTIC_PASSWORD=elasticpassword
  fi
  echo "$HELK_INFO_TAG Setting Elastic password to $ELASTIC_PASSWORD"
fi

echo "$HELK_INFO_TAG Setting Elastic license to $XPACK_LICENSE_TYPE"

# ********** Starting Elasticsearch *****************
echo "$HELK_INFO_TAG Running docker-entrypoint script.."
/usr/local/bin/docker-entrypoint.sh