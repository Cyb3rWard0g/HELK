#!/bin/bash

# HELK script: elasticsearch-entrypoint.sh
# HELK script description: sets elasticsearch configs and starts elasticsearch
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g), Nate Guagenti (@neu5ron)
# License: GPL-3.0

RED='\033[0;31m'
CYAN='\033[0;36m'
WAR='\033[1;33m'
STD='\033[0m'
# *********** Helk log tagging variables ***************
# For more efficient script editing/reading, and also if/when we switch to different install script language
HELK_INFO_TAG="${CYAN}[HELK-ES-DOCKER-INSTALLATION-INFO]${STD}"
HELK_ERROR_TAG="${RED}[HELK-ES-DOCKER-INSTALLATION-ERROR]${STD}"
HELK_WARNING_TAG="${WAR}[HELK-ES-DOCKER-INSTALLATION-WARNING]${STD}"

TOTAL_MEMORY=$(awk '/MemTotal/{printf "%.f", $2/1024}' /proc/meminfo)
# Check using more accurate MB for setting later
AVAILABLE_MEMORY=$(awk '/MemAvailable/{printf "%.f", $2/1024}' /proc/meminfo)

# *********** Setting Elasticsearch Memory ***************
# Check to make sure not set in docker config/runtime
if [[ -z "$HELK_ES_MEMORY" ]]; then
  # Check to make sure not statically set in config file
  if (grep -P "^#\-Xms\d+" "./config/jvm.options") && (grep -P "^#\-Xmx\d+" "./config/jvm.options"); then

    if [[ ${AVAILABLE_MEMORY} -le 1499 ]]; then
      echo -e "${HELK_ERROR_TAG} Not enough memory available to the docker container. There is only ${AVAILABLE_MEMORY}MBs.\nExiting script..."
      exit 1
    elif [[ ${AVAILABLE_MEMORY} -ge 1500 && ${AVAILABLE_MEMORY} -le 1999 ]]; then
      echo -e "${HELK_WARNING_TAG} Low memory available to the docker container. There is only ${AVAILABLE_MEMORY}MBs."
      ES_MEMORY="1000m"
    elif [[ ${AVAILABLE_MEMORY} -ge 2000 && ${AVAILABLE_MEMORY} -le 2499 ]]; then
      echo -e "${HELK_WARNING_TAG} Low memory available to the docker container. There is only ${AVAILABLE_MEMORY}MBs."
      ES_MEMORY="1200m"
    elif [[ ${AVAILABLE_MEMORY} -ge 2500 && ${AVAILABLE_MEMORY} -le 2999 ]]; then
      ES_MEMORY="1500m"
    elif [[ ${AVAILABLE_MEMORY} -ge 3000 && ${AVAILABLE_MEMORY} -le 4999 ]]; then
      ES_MEMORY="1750m"
    elif [[ ${AVAILABLE_MEMORY} -ge 5000 && ${AVAILABLE_MEMORY} -le 5999 ]]; then
      ES_MEMORY="2000m"
    elif [[ ${AVAILABLE_MEMORY} -ge 6000 && ${AVAILABLE_MEMORY} -le 7999 ]]; then
      ES_MEMORY="3000m"
    elif [[ ${AVAILABLE_MEMORY} -ge 8000 && ${AVAILABLE_MEMORY} -le 8999 ]]; then
      ES_MEMORY="3000m"
    elif [[ ${AVAILABLE_MEMORY} -ge 9000 && ${AVAILABLE_MEMORY} -le 9999 ]]; then
      ES_MEMORY="4000m"
    elif [[ ${AVAILABLE_MEMORY} -ge 10000 && ${AVAILABLE_MEMORY} -le 12999 ]]; then
      ES_MEMORY="5000m"
    elif [[ ${AVAILABLE_MEMORY} -ge 13000 && ${AVAILABLE_MEMORY} -le 15999 ]]; then
      ES_MEMORY="6500m"
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
    echo -e "${HELK_INFO_TAG} Setting ES_JAVA_OPTS to ${ES_JAVA_OPTS} from custom HELK \"algorithm\""
  else
    echo -e "${HELK_INFO_TAG} Setting ES_JAVA_OPTS to user defined (hardcoded) value from jvm.options"
  fi
else
  echo -e "${HELK_INFO_TAG} Setting ES_JAVA_OPTS to ${ES_JAVA_OPTS} from runtime docker config file"
fi


# ******** Checking License Type ***************
ENVIRONMENT_VARIABLES=$(env)

# ********** Starting Elasticsearch *****************
echo -e "${HELK_INFO_TAG} Running docker-entrypoint script.."
/usr/local/bin/docker-entrypoint.sh