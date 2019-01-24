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
KIBANA=$SERVER_HOST:$SERVER_PORT
KIBANA_ACCESS=http://kibana:$ELASTICSEARCH_PASSWORD@$KIBANA
TIME_FIELD="@timestamp"
DEFAULT_INDEX="logs-endpoint-winevent-sysmon-*"
DIR=/usr/share/kibana/dashboards

# *********** Waiting for Kibana port to be up ***************
echo "[++] Checking to see if kibana port is up..."
until curl -s $KIBANA -o /dev/null; do
    sleep 1
done

# *********** Waiting for Kibana server to be running ***************
echo "[++] Checking to see if kibana server is running..."
while [[ -z $(grep "Server running at http://$KIBANA" /usr/share/kibana/config/kibana_logs.log) ]]; do 
    sleep 1
done

# *********** Creating Kibana index-patterns ***************
declare -a index_patterns=("logs-endpoint-*" "logs-*" "logs-endpoint-winevent-sysmon-*" "logs-endpoint-winevent-security-*" "logs-endpoint-winevent-system-*" "logs-endpoint-winevent-application-*" "logs-endpoint-winevent-wmiactivity-*" "logs-endpoint-winevent-powershell-*" "mitre-attack-*" "elastalert_status" "elastalert_status_status" "elastalert_status_error" "elastalert_status_silence" "elastalert_status_past" "sysmon-join-*" "logs-endpoint-osquery-*")

echo "[+++] Creating Kibana Index Patterns..."
for index in ${!index_patterns[@]}; do
    echo "[++++++] creating kibana index ${index_patterns[${index}]}"
    curl -f -XPOST -H "Content-Type: application/json" -H "kbn-xsrf: true" \
    "$KIBANA_ACCESS/api/saved_objects/index-pattern/${index_patterns[${index}]}" \
    -d"{\"attributes\":{\"title\":\"${index_patterns[${index}]}\",\"timeFieldName\":\"$TIME_FIELD\"}}"
done

# *********** Making Sysmon the default index ***************
echo "[++] Making Sysmon the default index..."
curl -XPOST -H "Content-Type: application/json" -H "kbn-xsrf: true" \
"$KIBANA_ACCESS/api/kibana/settings/defaultIndex" \
-d"{\"value\":\"$DEFAULT_INDEX\"}"

# *********** Loading dashboards ***************
echo "[++] Loading Dashboards..."
for file in ${DIR}/*.json
do
    echo "[++++++] Loading dashboard file ${file}"  
    curl -XPOST "$KIBANA_ACCESS/api/kibana/dashboards/import" -H 'kbn-xsrf: true' \
    -H 'Content-type:application/json' -d @${file} || exit 1
done

# *********** Creating HELK User *********************
echo "[+++] Setting HELK's user password to $KIBANA_UI_PASSWORD"  
curl -s -H 'Content-Type:application/json' -XPUT $ELASTICSEARCH_ACCESS/_xpack/security/user/helk -d"
{
  \"password\" : \"$KIBANA_UI_PASSWORD\",
  \"roles\" : [ \"superuser\" ],
  \"full_name\" : \"The HELK\",
  \"email\" : \"helk@example.com\"
}
"
# *********** Create Roles *******************
curl -s -H 'Content-Type:application/json' -XPUT $ELASTICSEARCH_ACCESS/_xpack/security/role/hunters -d'
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
curl -s -H 'Content-Type:application/json' -XPUT $ELASTICSEARCH_ACCESS/_xpack/security/role/sysmon_hunters -d'
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
