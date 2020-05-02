#!/bin/bash

# HELK script: kibana-setup-index_patterns.sh
# HELK script description: Creates Kibana index patterns
# HELK build Stage: Alpha
# Author: Nate Guagenti (@neu5ron)
# License: GPL-3.0

# *********** Helk log tagging variables ***************
# For more efficient script editing/reading, and also if/when we switch to different install script language
TAG_NAME="SETUP-INDEX_PATTERNS"
HELK_INFO_TAG="HELK-KIBANA-DOCKER-$TAG_NAME-INFO:"
HELK_ERROR_TAG="HELK-KIBANA-DOCKER-$TAG_NAME-ERROR:"

# *********** Variables ***************
TIME_FIELD="@timestamp"
DEFAULT_INDEX_PATTERN="logs-endpoint-winevent-sysmon-*"
declare -a index_patterns=(
    "elastalert_status"
    "elastalert_status_error"
    "elastalert_status_past"
    "elastalert_status_silence"
    "elastalert_status_status"
    "indexme-*"
    "logs-*"
    "logs-endpoint-*"
    "logs-endpoint-winevent-*"
    "logs-endpoint-winevent-application-*"
    "logs-endpoint-winevent-etw-*"
    "logs-endpoint-winevent-powershell-*"
    "logs-endpoint-winevent-security-*"
    "logs-endpoint-winevent-sysmon-*"
    "logs-endpoint-winevent-system-*"
    "logs-endpoint-winevent-wmiactivity-*"
    "logs-network-*"
    "logs-network-zeek-*"
    "mitre-attack-*"
    "original-*"
    "parse-failures-*"
    "sysmon-join-*"
)

echo "$HELK_INFO_TAG Creating Kibana index patterns.."
for index_pattern in "${index_patterns[@]}"; do
  while true
    do
      echo "$HELK_INFO_TAG Creating index pattern ${index_pattern}.."
      ES_STATUS_CODE="$(curl -X POST -s -o /dev/null -w "%{http_code}" -u "${ELASTICSEARCH_CREDS}" "$KIBANA_HOST/api/saved_objects/index-pattern/${index_pattern}?overwrite=true" \
        -H 'Content-Type: application/json' \
        -H 'kbn-xsrf: true' \
        -d"{\"attributes\":{\"title\":\"${index_pattern}\",\"timeFieldName\":\"$TIME_FIELD\"}}" \
      )"
      if [ "$ES_STATUS_CODE" -eq 200 ]; then
        break
      else
        echo "$HELK_ERROR_TAG Error HTTP code ${ES_STATUS_CODE} while attempting creation of index pattern ${index_pattern}..."
        sleep 2
      fi
    done
done
# *********** Setting the default index pattern ***************
echo "$HELK_INFO_TAG Setting the default index pattern to ${DEFAULT_INDEX_PATTERN}."
until curl -X POST -u "${ELASTICSEARCH_CREDS}" "$KIBANA_HOST/api/kibana/settings/defaultIndex" \
  -H "Content-Type: application/json" -H "kbn-xsrf: true" \
  -d"{\"value\":\"${DEFAULT_INDEX_PATTERN}\"}"
do
  sleep 1
done