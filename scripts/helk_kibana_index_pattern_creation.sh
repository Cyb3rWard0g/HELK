#!/usr/bin/env bash

# HELK script: helk_kibana_index_pattern_creation.sh
# HELK script description: Creates Kibana index patterns automatically.
# HELK build version: 0.9 (BETA)
# HELK ELK version: 6.x
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

# References: 
# https://github.com/elastic/kibana/issues/3709 (https://github.com/hobti01)
# https://explainshell.com/explain?cmd=set+-euxo%20pipefail

set -euo pipefail
url="http://localhost:5601"
declare -A index_patterns=("sysmon-*"
                           "winevent-security-*"
                           "winevent-system-*" 
                           "winevent-application-*"
                           "powershell-*"
                           )
time_field="@timestamp"
# Create index pattern
# curl -f to fail on error
# For loop to create every single intex pattern
for index in ${!index_patterns[@]}; do 
  curl -f -XPOST -H "Content-Type: application/json" -H "kbn-xsrf: anything" \
  "$url/api/saved_objects/index-pattern/${index}" \
  -d"{\"attributes\":{\"title\":\"${index}\",\"timeFieldName\":\"$time_field\"}}"
done
# Make Sysmon the default index
curl -XPOST -H "Content-Type: application/json" -H "kbn-xsrf: anything" \
  "$url/api/kibana/settings/defaultIndex" \
  -d"{\"value\":\"sysmon-*\"}"