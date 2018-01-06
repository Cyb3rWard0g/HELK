#!/bin/bash

# HELK script: helk_kibana_setup.sh
# HELK script description: Creates Kibana index patterns, dashboards and visualizations automatically.
# HELK build version: 0.9 (BETA)
# HELK ELK version: 6.x
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

# References: 
# https://github.com/elastic/kibana/issues/3709 (https://github.com/hobti01)
# https://explainshell.com/explain?cmd=set+-euxo%20pipefail
# https://github.com/elastic/beats-dashboards/blob/master/load.sh
# https://github.com/elastic/kibana/issues/14872

# *********** Setting Variables ***************
KIBANA="http://localhost:5601"
TIME_FIELD="@timestamp"
DEFAULT_INDEX="sysmon-*"
DIR=/opt/helk/dashboards

# *********** Setting Index Pattern Array ***************
declare -a index_patterns=("*" "sysmon-*" "winevent-security-*" "winevent-system-*" "winevent-application-*" "powershell-*")

# *********** Waiting for Kibana to be available ***************
until curl -s localhost:5601 -o /dev/null; do
    sleep 1
done

# *********** Creating Kibana index-patterns ***************
for index in ${!index_patterns[@]}; do 
    curl -f -XPOST -H "Content-Type: application/json" -H "kbn-xsrf: anything" \
    "$KIBANA/api/saved_objects/index-pattern/${index_patterns[${index}]}" \
    -d"{\"attributes\":{\"title\":\"${index_patterns[${index}]}\",\"timeFieldName\":\"$TIME_FIELD\"}}"
done

# *********** Making Sysmon the default index ***************
curl -XPOST -H "Content-Type: application/json" -H "kbn-xsrf: anything" \
"$KIBANA/api/kibana/settings/defaultIndex" \
-d"{\"value\":\"$DEFAULT_INDEX\"}"

# *********** Loading dashboards ***************
for file in ${DIR}/*.json
do  
    echo "Loading dashboard ${NAME}:"
    curl -XPOST "$KIBANA/api/kibana/dashboards/import" -H 'kbn-xsrf:true' \
    -H 'Content-type:application/json' -d @${file} || exit 1
    echo
done