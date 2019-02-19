#!/bin/bash

# HELK script: kibana-setup.sh
# HELK script description: Creates Kibana index patterns, dashboards and visualizations automatically.
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# References: 
# https://github.com/elastic/kibana/issues/3709 (https://github.com/hobti01)
# https://explainshell.com/explain?cmd=set+-euxo%20pipefail
# https://github.com/elastic/beats-dashboards/blob/master/load.sh
# https://github.com/elastic/kibana/issues/14872
# https://github.com/elastic/stack-docker/blob/master/docker-compose.yml
# https://stackoverflow.com/a/42377880

# *********** Setting Variables ***************
KIBANA_URL=http://$SERVER_HOST:$SERVER_PORT
TIME_FIELD="@timestamp"
DEFAULT_INDEX="logs-endpoint-winevent-sysmon-*"
DIR=/usr/share/kibana/dashboards

# *********** Waiting for Kibana port to be up ***************
echo "[HELK-KIBANA-DOCKER-INSTALLATION-INFO] Checking to see if kibana port is up..."
until curl -s $KIBANA_URL -o /dev/null; do
    sleep 1
done

# *********** Waiting for Kibana server to be running ***************
echo "[HELK-KIBANA-DOCKER-INSTALLATION-INFO] Checking to see if kibana server is running..."
while [[ -z $(grep "Server running at http://$KIBANA" /usr/share/kibana/config/kibana_logs.log) ]]; do 
    sleep 1
done

# ******** Set Trial License Variables ***************
if [[ -n "$ELASTICSEARCH_PASSWORD" ]] && [[ -n "$ELASTICSEARCH_USERNAME" ]]; then
  # *********** Creating Kibana index-patterns ***************
  declare -a index_patterns=("logs-endpoint-*" "logs-*" "logs-endpoint-winevent-sysmon-*" "logs-endpoint-winevent-security-*" "logs-endpoint-winevent-system-*" "logs-endpoint-winevent-application-*" "logs-endpoint-winevent-wmiactivity-*" "logs-endpoint-winevent-powershell-*" "mitre-attack-*" "elastalert_status" "elastalert_status_status" "elastalert_status_error" "elastalert_status_silence" "elastalert_status_past" "sysmon-join-*")
  echo "[HELK-KIBANA-DOCKER-INSTALLATION-INFO] Creating Kibana Index Patterns..."
  for index in ${!index_patterns[@]}; do
      echo "[++++++] creating kibana index ${index_patterns[${index}]}"
      until curl -u $KIBANA_USER:$KIBANA_PASSWORD -X POST "$KIBANA_URL/api/saved_objects/index-pattern/${index_patterns[${index}]}" \
      -H "Content-Type: application/json" -H "kbn-xsrf: true" \
      -d"{\"attributes\":{\"title\":\"${index_patterns[${index}]}\",\"timeFieldName\":\"$TIME_FIELD\"}}"
      do
        sleep 1
      done
  done

  # *********** Making Sysmon the default index ***************
  echo "[HELK-KIBANA-DOCKER-INSTALLATION-INFO] Making Sysmon the default index..."
  until curl -u $KIBANA_USER:$KIBANA_PASSWORD -X POST -H "Content-Type: application/json" -H "kbn-xsrf: true" \
  "$KIBANA_URL/api/kibana/settings/defaultIndex" \
  -d"{\"value\":\"$DEFAULT_INDEX\"}"
  do
    sleep 1
  done

  # *********** Loading dashboards ***************
  echo "[HELK-KIBANA-DOCKER-INSTALLATION-INFO] Loading Dashboards..."
  for file in ${DIR}/*.json
  do
      echo "[++++++] Loading dashboard file ${file}"  
      until curl -u $KIBANA_USER:$KIBANA_PASSWORD -X POST "$KIBANA_URL/api/kibana/dashboards/import" -H 'kbn-xsrf: true' \
      -H 'Content-type:application/json' -d @${file}
      do
        sleep 1
      done
  done

  # *********** Creating HELK User *********************
  echo "[HELK-KIBANA-DOCKER-INSTALLATION-INFO] Setting HELK's user password to $KIBANA_UI_PASSWORD"  
  curl -u $ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD -X POST "$ELASTICSEARCH_URL/_xpack/security/user/helk" -H 'Content-Type: application/json' -d"
  {
    \"password\" : \"$KIBANA_UI_PASSWORD\",
    \"roles\" : [ \"superuser\" ],
    \"full_name\" : \"The HELK\",
    \"email\" : \"helk@example.com\"
  }
  "
  
  # *********** Create Roles *******************
  curl -u $ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD -X POST "$ELASTICSEARCH_URL/_xpack/security/role/hunters" -H 'Content-Type: application/json' -d'
  {
    "run_as": [],
    "cluster": [],
    "indices": [
      {
        "names": [ "logs-*" ],
        "privileges": [ "read" ]
      }
    ]
  }
  '
  curl -u $ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD -X POST "$ELASTICSEARCH_URL/_xpack/security/role/sysmon_hunters" -H 'Content-Type: application/json' -d'
  {
    "run_as": [],
    "cluster": [],
    "indices": [
      {
        "names": [ "logs-endpoint-winevent-sysmon-*" ],
        "privileges": [ "read" ]
      }
    ]
  }
  '
else
  # *********** Creating Kibana index-patterns ***************
  declare -a index_patterns=("logs-endpoint-*" "logs-*" "logs-endpoint-winevent-sysmon-*" "logs-endpoint-winevent-security-*" "logs-endpoint-winevent-system-*" "logs-endpoint-winevent-application-*" "logs-endpoint-winevent-wmiactivity-*" "logs-endpoint-winevent-powershell-*" "mitre-attack-*" "elastalert_status" "elastalert_status_status" "elastalert_status_error" "elastalert_status_silence" "elastalert_status_past" "sysmon-join-*")

  echo "[+++] Creating Kibana Index Patterns..."
  for index in ${!index_patterns[@]}; do
      echo "[++++++] creating kibana index ${index_patterns[${index}]}"
      until curl -X POST "$KIBANA_URL/api/saved_objects/index-pattern/${index_patterns[${index}]}" \
      -H "Content-Type: application/json" -H "kbn-xsrf: true" \
      -d"{\"attributes\":{\"title\":\"${index_patterns[${index}]}\",\"timeFieldName\":\"$TIME_FIELD\"}}"
      do
          sleep 1
      done
  done

  # *********** Making Sysmon the default index ***************
  echo "[++] Making Sysmon the default index..."
  until curl -X POST -H "Content-Type: application/json" -H "kbn-xsrf: true" \
  "$KIBANA_URL/api/kibana/settings/defaultIndex" \
  -d"{\"value\":\"$DEFAULT_INDEX\"}"
  do
      sleep 1
  done

  # *********** Loading dashboards ***************
  echo "[+++] Loading Dashboards..."
  for file in ${DIR}/*.json
  do  
      echo "[++++++] Loading dashboard file ${file}"
      until curl -X POST "$KIBANA_URL/api/kibana/dashboards/import" -H 'kbn-xsrf: true' \
      -H 'Content-type:application/json' -d @${file}
      do
          sleep 1
      done
  done
fi