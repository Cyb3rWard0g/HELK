#!/bin/bash

# HELK script: kibana-export-objects.sh
# HELK script description: Export all the saved objects from Kibana and saved them in separate files and grouped in a directory by type
# HELK build stage: Alpha
# Authors: Nate Guagenti (@neu5ron), Thomas Castronovo (@troplolBE)
# License: GPL-3.0

_URL=$1
KIBANA_URL=${_URL:=http://127.0.0.1:5601}

#Cycle trough all the different object types
for item in config index-pattern search visualization dashboard url map canvas-workpad canvas-element timelion; do

    #Cycle through all the saved objects of that category
    for id in $(curl -sk -u helk:hunting "${KIBANA_URL}/api/saved_objects/_find?type=${item}&per_page=1000" | jq -r '.saved_objects[] | .id'); do
        #Create and go to directory
        mkdir -p ${item}
        cd ${item}

        #Request saved object
        object=$(curl -sk -XPOST -u helk:hunting \
            "${KIBANA_URL}/api/saved_objects/_export" \
            -H "kbn-xsrf: true" \
            -H "Content-Type: application/json" \
            -d"
            { \"objects\":
                [
                    {
                        \"type\": \"${item}\",
                        \"id\": \"${id}\"
                    }
                ]
            }
              ")
        #Gather object name and object file
        if [[ "$item" == "config" || "$item" == "index-pattern" ]]; then
            filename=$(echo "$object" | jq -r '.id' | sed -e 's/\./_/g')
        else
            filename=$(echo "$object" | jq -r '.attributes.title' | sed -e 's/ ,/_/g')
        fi

        if [ "$filename" -eq "null" ]; then
            echo "Oh no, we have a problem..."
        else
            echo "filename = ${filename}"
        fi

        echo "filename second = $filename"
        file="${filename}_REL.ndjson"

        #Write to file
        echo "Exporting ${item} named ${id} as ${file}" > /dev/stderr
        echo "$object" >> "$file"
    done

    # Sort index for idempotence
    #jq '. | sort' < index.json > index2.json && mv index2.json index.json
    cd ..
done
exit
# Save default index
echo "Exporting default index pattern setting."
curl -s "${KIBANA_URL}/api/kibana/settings" | jq '.settings.defaultIndex' > index-pattern/default.json
