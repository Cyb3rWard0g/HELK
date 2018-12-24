#!/bin/bash

# HELK script: logstash-entrypoint.sh
# HELK script description: Pushes output templates to ES and starts Logstash
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# *********** Environment Variables ***************
if [[ -z "$ELASTICSEARCH_URL" ]]; then
    export ELASTICSEARCH_URL="http://helk-elasticsearch:9200"
fi
echo "[HELK-ES-DOCKER-INSTALLATION-INFO] Setting Elasticsearch URL to $ELASTICSEARCH_URL"

# ********* Setting LS_JAVA_OPTS ***************
if [[ -z "$LS_JAVA_OPTS" ]]; then
    LS_MEMORY=$(awk '/MemAvailable/{printf "%.f", $2/1024/4}' /proc/meminfo)
    export LS_JAVA_OPTS="-Xms${LS_MEMORY}m -Xmx${LS_MEMORY}m"
fi
echo "[HELK-DOCKER-INSTALLATION-INFO] Setting LS_JAVA_OPTS to $LS_JAVA_OPTS"

# *********** Looking for ES ***************
echo "[HELK-DOCKER-INSTALLATION-INFO] Waiting for elasticsearch URI to be accessible.."
until curl -s $ELASTICSEARCH_URL -o /dev/null; do
    sleep 1
done

echo "[HELK-DOCKER-INSTALLATION-INFO] Uploading templates to elasticsearch.."
DIR=/usr/share/logstash/output_templates
for file in ${DIR}/*.json
do
    template_name=$(echo $file | sed -r ' s/^.*\/[0-9]+\-//');
    echo "[HELK-DOCKER-INSTALLATION-INFO] Uploading $template_name template to elasticsearch..";
    curl -s -H 'Content-Type: application/json' -XPUT "$ELASTICSEARCH_URL/_template/$template_name" -d@${file};
done

# ********** Install Plugin *****************
echo "[HELK-DOCKER-INSTALLATION-INFO] Installing Logstash plugins.."
logstash-plugin install logstash-filter-prune

# ********** Starting Logstash *****************
echo "[HELK-DOCKER-INSTALLATION-INFO] Running docker-entrypoint script.."
/usr/local/bin/docker-entrypoint