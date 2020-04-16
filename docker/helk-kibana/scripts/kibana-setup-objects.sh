#!/bin/bash

# HELK script: kibana-setup-objects.sh
# HELK script description: Creates, loads, and updates Kibana objects such as Visualizations, Dashboards, etc...
# HELK build Stage: Alpha
# Author: Nate Guagenti (@neu5ron), Thomas Castronovo (@troplolBE)
# License: GPL-3.0

_URL=$1
KIBANA_URL=${_URL:=http://127.0.0.1:5601}
KIBANA_VERSION=$(curl -sI ${KIBANA_URL} | awk '/kbn-version/ { print $2 }')

total_imported=0
total_failed=0

echo "Please be patient as we import 100+ custom dashboards, visualizations, and searches..."

for item in config index-pattern search visualization dashboard url map canvas-workpad canvas-element timelion; do
    cd ${item} 2>/dev/null || continue
    file="${item}.ndjson"
    total=$(wc -l ${item})
    failed=0
    echo "Importing ${total} ${item}s"
    response=$(
    curl -s -XPOST \
        "${KIBANA_URL}/api/saved_objects/_import?overwrite=true" \
        -H "kbn-xsrf: true" \
        --form file=@"${file}"
    )
    result=$(echo "${response}" | jq -r '.success')
    imported=$(echo "${response}" | jq -r '.successCount')
    if [[ ${result} == "true" ]]; then
        echo "All ${total} ${item}s have succesfully been imported in Kibana."
    else
        failed=$((${objects}-${imported}))
        echo -e "Failed to import ${failed} ${item}s: \n ${response}\n"
    fi
    total_imported=$((${total_imported}+${imported}))
    total_failed=$((${total_failed}+${failed}))
    cd ..
done

# Set default index
defaultIndex=$(jq -r '.userValue' index-pattern/default.json)

echo "Setting defaultIndex to ${defaultIndex}" > /dev/stderr
curl -s -XPOST -H"kbn-xsrf: true" -H"Content-Type: application/json" \
    "${KIBANA_URL}/api/kibana/settings/defaultIndex" -d"{\"value\": \"${defaultIndex}\"}" >/dev/null

echo "Imported: ${total_imported}"
echo "Failed: ${total_failed}"
