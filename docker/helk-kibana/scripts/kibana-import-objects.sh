#!/bin/bash

# HELK script: kibana-import-objects.sh
# HELK script description: Imports all the saved objects back to Kibana.
# HELK build stage: Alpha
# Author: Thomas Castronovo (@troplolBE), Nate Guagenti (@neu5ron)
# License: GPL-3.0

_URL=$1
KIBANA_URL=${_URL:=https://127.0.0.1:5601}

created=0
failed=0

echo "Please be patient as we import 100+ custom dashboards, visualizations, and searches..."

for item in config map canvas-workpad canvas-element lens query index-pattern visualization search dashboard url; do
    cd ${item} 2>/dev/null || continue

    for file in ${item}/*.ndjson; do
        response=$(
        curl -sk -XPOST -u helk:hunting \
            "${KIBANA_URL}/api/saved_objects/_import?overwrite=true" \
            -H "kbn-xsrf: true" \
            --form file=@"${file}"
        )
        result=$(echo "${response}" | jq -r '.success')
        if [[ ${result} == "true" ]]; then
            created=$((created+1))
        else
            failed=$((failed+1))
            echo -e "Failed importing ${item} named ${file}: \n ${response}\n"
        fi
    done
    cd ..
done

# Set default index
defaultIndex=$(jq -r '.userValue' index-pattern/default.json)

echo "Setting defaultIndex to ${defaultIndex}" > /dev/stderr
curl -s -XPOST -H"kbn-xsrf: true" -H"Content-Type: application/json" \
    "${KIBANA_URL}/api/kibana/settings/defaultIndex" -d"{\"value\": \"${defaultIndex}\"}" >/dev/null

echo "Created: ${created}"
echo "Failed: ${failed}"
