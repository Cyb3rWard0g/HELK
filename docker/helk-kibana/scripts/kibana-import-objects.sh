#!/bin/bash

# HELK script: kibana-import-objects.sh
# HELK script description: Imports all the saved objects back to Kibana.
# HELK build stage: Alpha
# Author: Thomas Castronovo (@troplolBE), Nate Guagenti (@neu5ron)
# License: GPL-3.0

DIR=/usr/share/kibana/objects
ARRAY=()
DEFAULT_KIBANA_CONFIG_FILE_NAME="default-kibana-config.ndjson"

created=0
failed=0

#Function to import files to Kibana
#Argument 1 = File to import
#Argument 2 = Retry of import

function importFile
{
    local file=${1}
    local retry=${2}

    # Setting configs works different, also want to set one whole file versus multiple that could have conflicts / cause confusion 
    if [[ "$item" == "config" ]] && [[ "$file" == "$DEFAULT_KIBANA_CONFIG_FILE_NAME" ]]; then
        #python 2 requires 'json.dumps', because json is returned as unicode and the kibana settings api does not support JSON like normal 
        kibana_attributes=$(< "${file}" python -c "import sys, json; print(json.dumps(json.load(sys.stdin)['attributes']))")
        response=$(
        curl -s -XPOST "${KIBANA_HOST}/api/kibana/settings" \
            -H "kbn-xsrf: true" \
            -H "Content-Type: application/json" \
            -d "@-" \
            <<< "{ \"changes\": $kibana_attributes }"
        )
    else
        response=$(
        curl -sk -XPOST -u "${ELASTICSEARCH_CREDS}" \
            "${KIBANA_HOST}/api/saved_objects/_import?overwrite=true" \
            -H "kbn-xsrf: true" \
            --form file=@"${file}"
        )
    fi
    result=$(echo "${response}" | grep -w "success" | cut -d ',' -f 1 | cut -d ':' -f 2 | sed -E 's/[^-[:alnum:]]//g')
    if [[ "${result}" == "true" ]]; then
        created=$((created+1))
        echo "Successfully imported ${item} named ${file}"
    else
        if [[ ${retry} -ne 1 ]]; then
            fail="${DIR}/${item}/${file}"
            ARRAY+=(${fail})
        else
            failed=$((failed+1))
        fi
        echo -e "Failed to import ${item} named ${file}: \n ${response}\n"
    fi
}

#Go to the right directory to find objects
cd ${DIR}

for item in config map canvas-workpad canvas-element lens query index-pattern search visualization dashboard url; do
    cd ${item} 2>/dev/null || continue

    for file in *.ndjson; do
        echo "$file"
        importFile ${file} 0
    done
    cd ..
done

echo -e "Files that failed:\n${ARRAY[@]}"
echo "Re-trying to import the failed files..."

echo "length of array is ${#ARRAY[@]}"
if [[ "${#ARRAY[@]}" -ne "0" ]]; then
    for file in "${ARRAY[@]}"; do
        echo "${file}"
        importFile ${file} 1
    done
fi

echo "Created: ${created}"
echo "Failed: ${failed}"
