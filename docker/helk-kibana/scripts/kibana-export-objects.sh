#!/bin/bash

# HELK script: kibana-export-objects.sh
# HELK script description: Export all the saved objects from Kibana and saved them in separate files and grouped in a directory by type
# HELK build stage: Alpha
# Authors: Nate Guagenti (@neu5ron), Thomas Castronovo (@troplolBE)
# License: GPL-3.0

KIBANA_HOST="$1"
ELASTICSEARCH_CREDS="$2"
DIR=$3

exports=0
failed=0

#Go to directory
cd $DIR

#Cycle trough all the different object types
for item in config index-pattern search visualization dashboard url map canvas-workpad canvas-element timelion; do
    first=1

    #Cycle through all the saved objects of that category
    for id in $(curl -sk -u "${ELASTICSEARCH_CREDS}" "${KIBANA_HOST}/api/saved_objects/_find?type=${item}&per_page=1000" | jq -r '.saved_objects[] | .id'); do
        #Check first iteration
        if [ $first -eq 1 ]; then
            #Create and go to directory
            mkdir -p ${item}
            cd ${item}
            first=0
        fi
        #Request saved object
        object=$(curl -sk -XPOST -u "${ELASTICSEARCH_CREDS}" \
            "${KIBANA_HOST}/api/saved_objects/_export" \
            -H "kbn-xsrf: true" \
            -H "Content-Type: application/json" \
            -d"
            { \"objects\":
                [
                    {
                        \"type\": \"${item}\",
                        \"id\": \"${id}\"
                    }
                ],
                \"excludeExportDetails\": true,
                \"includeReferencesDeep\": false
            }
              ")
        #Check export went well
        if [ $(echo "$object" | jq -r '.statusCode') == "400" ]; then
            echo "Error while exporting ${id}..."
            echo -e "Error:\n${object}"
            failed=$(($failed+1))
            continue;
        fi
        exports=$(($exports+1))
        #Gather object name and object file
        if [[ "$item" == "config" || "$item" == "index-pattern" ]]; then
            filename=$(echo "$object" | jq -r '.id')
        else
            filename=$(echo "$object" | jq -r '.attributes.title')
        fi
        filename=${filename//[^A-Za-z0-9]/_}
        filename=$(echo "$filename" | sed -E 's/^(.*?[^_]+)(_)*$/\1/g')
        file="${filename}.ndjson"

        #Write to file
        echo "Exporting ${item} named ${filename} as ${file}" > /dev/stderr
        echo "$object" >> "$file"
    done
    if [ $(basename $(pwd)) == "${item}" ]; then
        cd ..
    fi
done

echo "Successfully exported ${exports} objects !"
if [[ $failed -ne 0 ]]; then
    echo "Failed to export ${failed} objects !"
fi
