#!/bin/bash

# HELK script: logstash-entrypoint.sh
# HELK script description: Pushes output templates to ES and starts Logstash
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# *********** Password for Elasticsearch Backend ********
if [[ -z "$ELASTIC_PASSWORD" ]]; then
  ELASTIC_PASSWORD=elasticpassword
fi
echo "[HELK-ES-DOCKER-INSTALLATION-INFO] Setting Elasticsearch backend password to $ELASTIC_PASSWORD"

if [[ -z "$ELASTIC_HOST" ]]; then
  ELASTIC_HOST=helk-elasticsearch
fi
echo "[HELK-ES-DOCKER-INSTALLATION-INFO] Setting Elasticsearch host name to $ELASTIC_HOST"

if [[ -z "$ELASTIC_PORT" ]]; then
  ELASTIC_PORT=9200
fi
echo "[HELK-ES-DOCKER-INSTALLATION-INFO] Setting Elasticsearch port to $ELASTIC_PORT"

if [[ -z "$ELASTICSEARCH_ACCESS" ]]; then
  ELASTICSEARCH_ACCESS=http://elastic:$ELASTIC_PASSWORD@$ELASTIC_HOST:$ELASTIC_PORT
fi
echo "[HELK-ES-DOCKER-INSTALLATION-INFO] Setting custom ELasticsearch URL with credentials to $ELASTICSEARCH_ACCESS"

# ********* Setting LS_JAVA_OPTS ***************
if [[ -z "$LS_JAVA_OPTS" ]]; then
  LS_MEMORY=$(awk '/MemAvailable/{printf "%.f", $2/1024/4}' /proc/meminfo)
  export LS_JAVA_OPTS="-Xms${LS_MEMORY}m -Xmx${LS_MEMORY}m"
fi
echo "[HELK-DOCKER-INSTALLATION-INFO] Setting LS_JAVA_OPTS to $LS_JAVA_OPTS"

# *********** Looking for ES ***************
echo "[HELK-DOCKER-INSTALLATION-INFO] Waiting for elasticsearch URI to be accessible.."
until curl -s $ELASTICSEARCH_ACCESS -o /dev/null; do
    sleep 1
done

echo "[HELK-DOCKER-INSTALLATION-INFO] Uploading templates to elasticsearch.."
DIR=/usr/share/logstash/output_templates
for file in ${DIR}/*.json
do
    template_name=$(echo $file | sed -r ' s/^.*\/[0-9]+\-//');
    echo "[HELK-DOCKER-INSTALLATION-INFO] Uploading $template_name template to elasticsearch..";
    curl -s -H 'Content-Type: application/json' -XPUT $ELASTICSEARCH_ACCESS/_template/$template_name -d@${file};
    sleep 1
done

# ****** Updating Pipeline configs ***********
for config in /usr/share/logstash/pipeline/*-output.conf
do
    echo "[HELK-LOGSTASH-INSTALLATION-INFO] Updating pipeline config $config..."
    sed -i "s/#password \=>.*$/password \=> \'${ELASTIC_PASSWORD}\'/g" ${config}
done

# ********** Install Plugin *****************
echo "[HELK-DOCKER-INSTALLATION-INFO] Installing Logstash plugins.."
logstash-plugin install logstash-filter-prune

# ********** Starting Logstash *****************
echo "[HELK-DOCKER-INSTALLATION-INFO] Running docker-entrypoint script.."
/usr/local/bin/docker-entrypoint


