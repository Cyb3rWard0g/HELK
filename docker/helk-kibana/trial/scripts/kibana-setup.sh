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

# *********** Setting Variables ***************
KIBANA=helk-kibana:5601
KIBANA_ACCESS=http://kibana:"kibanapassword"@helk-kibana:5601
ELASTICSEARCH_ACCESS=http://elastic:"elasticpassword"@helk-elasticsearch:9200
TIME_FIELD="@timestamp"
DEFAULT_INDEX="logs-endpoint-winevent-sysmon-*"
DIR=/usr/share/kibana/dashboards

# *********** Setting Index Pattern Array ***************
declare -a index_patterns=("logs-endpoint-*" "logs-*" "logs-endpoint-winevent-sysmon-*" "logs-endpoint-winevent-security-*" "logs-endpoint-winevent-system-*" "logs-endpoint-winevent-application-*" "logs-endpoint-winevent-wmiactivity-*" "logs-endpoint-winevent-powershell-*" "mitre-attack-*")

# *********** Waiting for Kibana to be available ***************
echo "[++] Checking to see if kibana is up..."
until curl -v $KIBANA -o /dev/null; do
    sleep 1
done

# *********** Creating Kibana index-patterns ***************
echo "[++] Creating Kibana Index Patterns..."
for index in ${!index_patterns[@]}; do 
    curl -f -XPOST -H "Content-Type: application/json" -H "kbn-xsrf: anything" \
    "$KIBANA_ACCESS/api/saved_objects/index-pattern/${index_patterns[${index}]}" \
    -d"{\"attributes\":{\"title\":\"${index_patterns[${index}]}\",\"timeFieldName\":\"$TIME_FIELD\"}}"
done

# *********** Making Sysmon the default index ***************
echo "[++] Making Sysmon the default index..."
curl -XPOST -H "Content-Type: application/json" -H "kbn-xsrf: anything" \
"$KIBANA_ACCESS/api/kibana/settings/defaultIndex" \
-d"{\"value\":\"$DEFAULT_INDEX\"}"

# *********** Loading dashboards ***************
echo "[++] Loading Dashboards..."
for file in ${DIR}/*.json
do  
    curl -XPOST "$KIBANA_ACCESS/api/kibana/dashboards/import" -H 'kbn-xsrf:true' \
    -H 'Content-type:application/json' -d @${file} || exit 1
done

# *********** Creating HELK User *********************
curl -s -H 'Content-Type:application/json' -XPUT $ELASTICSEARCH_ACCESS/_xpack/security/user/helk -d"
{
  \"password\" : \"hunting\",
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
# *********** Creating Cyb3rWard0g User *********************
curl -s -H 'Content-Type:application/json' -XPUT $ELASTICSEARCH_ACCESS/_xpack/security/user/Cyb3rWard0g -d'
{
  "password" : "Wh@tTh3H3lk",
  "roles" : [ "kibana_user","hunters" ],
  "full_name" : "Roberto Rodriguez",
  "email" : "cyb3rward0g@example.com"
}
'
# *********** Creating Sysmon User *********************
curl -s -H 'Content-Type:application/json' -XPUT $ELASTICSEARCH_ACCESS/_xpack/security/user/sysmon_hunter -d'
{
  "password" : "sysmon",
  "roles" : [ "kibana_user","sysmon_hunters" ],
  "full_name" : "Sysmon Hunter",
  "email" : "sysmon_hunter@example.com"
}
'
