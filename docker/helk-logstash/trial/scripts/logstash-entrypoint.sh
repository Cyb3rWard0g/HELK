#!/bin/bash

# HELK script: logstash-setup.sh
# HELK script description: Pushes output templates to ES and starts Logstash
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# ********* Setting LS_JAVA_OPTS ***************
if [[ ! -z "$LS_JAVA_OPTS" ]]; then
  echo "[HELK-DOCKER-INSTALLATION-INFO] Setting LS_JAVA_OPTS to $LS_JAVA_OPTS"
else
  # ****** Setup heap size *****
    LS_MEMORY=$(awk '/MemAvailable/{printf "%.f", $2/1024/1024/2}' /proc/meminfo)
    echo "[HELK-DOCKER-INSTALLATION-INFO] Setting LS_HEAP_SIZE to ${LS_MEMORY}.."
    export LS_JAVA_OPTS="-Xms${LS_MEMORY}g -Xmx${LS_MEMORY}g"
fi

ELASTICSEARCH_ACCESS=http://elastic:"elasticpassword"@helk-elasticsearch:9200
# *********** Looking for ES ***************
echo "[HELK-DOCKER-INSTALLATION-INFO] Waiting for elasticsearch URI to be accessible.."
until curl -s $ELASTICSEARCH_ACCESS -o /dev/null; do
    sleep 1
done

DIR=/usr/share/logstash/output_templates
for file in ${DIR}/*.json
    do
        template_name=$(echo $file | sed -r ' s/^.*\/[0-9]+\-//');
        curl -H 'Content-Type: application/json' -XPUT "$ELASTICSEARCH_ACCESS/_template/$template_name" -d@${file};
done

exec "$@"


