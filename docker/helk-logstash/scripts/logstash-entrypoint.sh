#!/bin/bash

# HELK script: logstash-entrypoint.sh
# HELK script description: Handles additional entrypoint scripts and configures Logstash server
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0
# References:
# https://github.com/nginxinc/docker-nginx/blob/master/entrypoint/docker-entrypoint.sh

set -e

RED='\033[0;31m'
CYAN='\033[0;36m'
WAR='\033[1;33m'
STD='\033[0m'

# *********** Helk log tagging variables ***************
# For more efficient script editing/reading, and also if/when we switch to different install script language
HELK_INFO_TAG="${CYAN}[HELK-LOGSTASH-DOCKER-INSTALLATION-INFO]${STD}"
HELK_ERROR_TAG="${RED}[HELK-LOGSTASH-DOCKER-INSTALLATION-ERROR]${STD}"
HELK_WARNING_TAG="${WAR}[HELK-LOGSTASH-DOCKER-INSTALLATION-WARNING]${STD}"

if /usr/bin/find "/usr/share/logstash/entrypoint/" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read v; then
    echo -e "${HELK_INFO_TAG} /usr/share/logstash/entrypoint/ is not empty, attempting to run entrypoint scripts"

    echo -e "${HELK_INFO_TAG} Looking for shell scripts in /usr/share/logstash/entrypoint/"
    find "/usr/share/logstash/entrypoint/" -follow -type f -print | sort -V | while read -r f; do
        case "$f" in
            *.sh)
                if [ -x "$f" ]; then
                    echo -e "${HELK_INFO_TAG} Launching $f";
                    "$f"
                else
                    # warn on shell scripts without exec bit
                    echo -e "${HELK_WARNING_TAG} Ignoring $f, not executable";
                fi
                ;;
            *) echo -e "${HELK_WARNING_TAG} Ignoring $f";;
        esac
    done

    echo -e "${HELK_INFO_TAG} Configuration complete; ready for start up"
else
    echo -e "${HELK_WARNING_TAG} No files found in /usr/share/logstash/entrypoint/, skipping configuration"
fi

# ********** Install Plugins *****************
echo -e "${HELK_INFO_TAG} Checking Logstash plugins.."
# check if has been 30 days since plugins have been updated
if test -f "$plugins_time_file"; then
  plugins_last_time=$(date -d "$(<"$plugins_time_file")" '+%s')
  plugins_current_time=$(date -d "$(<"$plugins_time_file")" '+%s')
  plugins_day_diff=$(( ( plugins_current_time - plugins_last_time )/(60*60*24) ))
  if [[ "$plugins_day_diff" -ge 30 ]]; then
    plugins_oudated="yes"
    echo -e "${HELK_INFO_TAG} Plugins have not been updated in over 30 days.."
  else
    plugins_oudated="no"
  fi
else
  plugins_oudated="yes"
fi
# Test a few plugins determine if probably all already installed
if ( logstash-plugin list  2> /dev/null | grep 'logstash-filter-prune' ) && ( logstash-plugin list  2> /dev/null | grep 'logstash-input-wmi' ); then
  plugins_previous_install="yes"
  echo -e "${HELK_INFO_TAG} Plugins from previous install detected.."
else
  plugins_previous_install="no"
  echo -e "${HELK_INFO_TAG} Plugins from previous install not detected.."
  echo -e "${HELK_INFO_TAG} Updating Logstash plugins over the internet for first run.."
  logstash-plugin update
fi
# If have not been updated in X time or not installed at all.. then install them
if [[ ${plugins_previous_install} = "no" ]] || [[ ${plugins_oudated} = "yes" ]]; then
	if [[ -f "/usr/share/logstash/plugins/helk-offline-logstash-codec_and_filter_plugins.zip" ]] && [[  -f "/usr/share/logstash/plugins/helk-offline-logstash-input-plugins.zip" ]] && [[  -f "/usr/share/logstash/plugins/helk-offline-logstash-output-plugins.zip" ]]; then
    echo -e "${HELK_INFO_TAG} Installing Logstash plugins via offline package.."
	  logstash-plugin install file:///usr/share/logstash/plugins/helk-offline-logstash-codec_and_filter_plugins.zip
	  logstash-plugin install file:///usr/share/logstash/plugins/helk-offline-logstash-input-plugins.zip
	  logstash-plugin install file:///usr/share/logstash/plugins/helk-offline-logstash-output-plugins.zip
  else
    echo -e "${HELK_ERROR_TAG} Logstash plugins not detected.."
    echo -e "${HELK_INFO_TAG} Please open a github ticket"
    exit 1
  fi
  printf "%s" "$(date +"%Y-%m-%d %T")" > "$plugins_time_file"
else
  echo -e "${HELK_INFO_TAG} Logstash plugins already installed and up to date.."
fi

# ********* Setting LS_JAVA_OPTS ***************
if [[ -z "$LS_JAVA_OPTS" ]]; then
  while true; do
    # Check using more accurate MB
    AVAILABLE_MEMORY=$(awk '/MemAvailable/{printf "%.f", $2/1024}' /proc/meminfo)
    if [[ "$AVAILABLE_MEMORY" -ge 700 ]] && [[ "$AVAILABLE_MEMORY" -le 999 ]]; then
      echo -e "${HELK_WARNING_TAG} Low memory available to the docker container. There is only ${AVAILABLE_MEMORY}MBs."
      LS_MEMORY="200m"
      LS_MEMORY_HIGH="600m"
    elif [[ "$AVAILABLE_MEMORY" -ge 1000 ]] && [[ "$AVAILABLE_MEMORY" -le 1599 ]]; then
      LS_MEMORY="300m"
      LS_MEMORY_HIGH="850m"
    elif [[ "$AVAILABLE_MEMORY" -ge 1600 ]] && [[ "$AVAILABLE_MEMORY" -le 1999 ]]; then
      LS_MEMORY="400m"
      LS_MEMORY_HIGH="1000m"
    elif [[ "$AVAILABLE_MEMORY" -ge 2000 ]] && [[ "$AVAILABLE_MEMORY" -le 2999 ]]; then
      LS_MEMORY="600m"
      LS_MEMORY_HIGH="1000m"
    elif [[ "$AVAILABLE_MEMORY" -ge 3000 ]] && [[ "$AVAILABLE_MEMORY" -le 4999 ]]; then
      LS_MEMORY="600m"
      LS_MEMORY_HIGH="1500m"
    elif [[ "$AVAILABLE_MEMORY" -gt 5000 ]]; then
      # Set high & low, so logstash doesn't use everything unnecessarily, it will usually flux up and down in usage -- and doesn't "severely" despite what everyone seems to believe
      LS_MEMORY="$(( AVAILABLE_MEMORY / 4 ))m"
      LS_MEMORY_HIGH="$(( AVAILABLE_MEMORY / 2 ))m"
      if [[ "$AVAILABLE_MEMORY" -gt 31000 ]]; then
        LS_MEMORY="8000m"
        LS_MEMORY_HIGH="31000m"
      fi
    else
      echo -e "${HELK_WARNING_TAG} ${LS_MEMORY}MBs is not enough memory for Logstash yet.."
      sleep 5
    fi
    export LS_JAVA_OPTS="${HELK_LOGSTASH_JAVA_OPTS} -Xms${LS_MEMORY} -Xmx${LS_MEMORY_HIGH} "
    break
  done
fi
echo -e "${HELK_INFO_TAG} Setting LS_JAVA_OPTS to $LS_JAVA_OPTS"

# ********* Setting Logstash PIPELINE_WORKERS ***************
if [[ -z "$PIPELINE_WORKERS" ]]; then
  # Get total CPUs/cores as reported by OS
  TOTAL_CORES=$(getconf _NPROCESSORS_ONLN 2>/dev/null)
  # try one more way
  [[ -z "$TOTAL_CORES" ]] && TOTAL_CORES=$(getconf NPROCESSORS_ONLN)
  # Unable to get reported cores
  if [[ -z "$TOTAL_CORES" ]]; then
    TOTAL_CORES=1
    echo -e "${HELK_WARNING_TAG} unable to get number of CPUs/cores as reported by the OS"
  fi
  # Set workers based on available cores
  if [[ "$TOTAL_CORES" -ge 1 ]] && [[ "$TOTAL_CORES" -le 3 ]]; then
    PIPELINE_WORKERS=1
    # Divide by 2
  elif [[ "$TOTAL_CORES" -ge 4 ]]; then
    PIPELINE_WORKERS="$(( TOTAL_CORES / 2 ))"
  # some unknown number
  else
    echo -e "${HELK_WARNING_TAG} reported CPUs/cores not an integer? not greater or equal to 1.."
    PIPELINE_WORKERS=1
  fi
  export PIPELINE_WORKERS
fi
echo -e "${HELK_INFO_TAG} Setting PIPELINE_WORKERS to ${PIPELINE_WORKERS}"

# ********** Starting Logstash *****************
echo -e "${HELK_INFO_TAG} Running docker-entrypoint script.."
/usr/local/bin/docker-entrypoint