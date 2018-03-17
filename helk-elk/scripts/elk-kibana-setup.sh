#!/bin/bash

# HELK script: elk-kibana-setup.sh
# HELK script description: Creates Kibana index patterns, dashboards and visualizations automatically.
# HELK build version: 0.9 (Alpha)
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
DEFAULT_INDEX="logs-endpoint-winevent-sysmon-*"
DIR=/opt/helk/dashboards
SIGMA_DIR=/opt/helk/sigma

# *********** Setting Index Pattern Array ***************
declare -a index_patterns=("logs-endpoint-*" "logs-*" "logs-endpoint-winevent-sysmon-*" "logs-endpoint-winevent-security-*" "logs-endpoint-winevent-system-*" "logs-endpoint-winevent-application-*" "logs-endpoint-winevent-wmiactivity-*" "logs-endpoint-winevent-powershell-*")

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

# *********** Loading Sigma searches ***************
cd $SIGMA_DIR
tools/sigmac -t kibana -c tools/config/helk.yml -Ooutput=curl -o import-sigma-to-kibana.sh -r rules/
. import-sigma-to-kibana.sh
