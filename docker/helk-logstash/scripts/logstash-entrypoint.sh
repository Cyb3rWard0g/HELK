#!/bin/bash

# HELK script: logstash-entrypoint.sh
# HELK script description: Pushes output templates to ES and starts Logstash
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# *********** Environment Variables ***************
DIR=/usr/share/logstash/output_templates

if [[ -z "$ELASTICSEARCH_URL" ]]; then
    export ELASTICSEARCH_URL="http://helk-elasticsearch:9200"
fi
echo "[HELK-LOGSTASH-DOCKER-INSTALLATION-INFO] Setting Elasticsearch URL to $ELASTICSEARCH_URL"

# ******** Set Trial License Variables ***************
if [[ -n "$ELASTIC_PASSWORD" ]]; then
  if [[ -z "$ELASTIC_USERNAME" ]]; then
    ELASTIC_USERNAME=elastic
  fi
  echo "[HELK-KIBANA-DOCKER-INSTALLATION-INFO] Setting Elasticsearch's username to access Elasticsearch to $ELASTIC_USERNAME"

  if [[ -z "$ELASTIC_HOST" ]]; then
    ELASTIC_HOST=helk-elasticsearch
  fi
  echo "[HELK-LOGSTASH-DOCKER-INSTALLATION-INFO] Setting Elasticsearch host name to $ELASTIC_HOST"

  if [[ -z "$ELASTIC_PORT" ]]; then
    ELASTIC_PORT=9200
  fi
  echo "[HELK-LOGSTASH-DOCKER-INSTALLATION-INFO] Setting Elasticsearch port to $ELASTIC_PORT"

  # ****** Updating Pipeline configs ***********
  for config in /usr/share/logstash/pipeline/*-output.conf
  do
      echo "[HELK-LOGSTASH-INSTALLATION-INFO] Updating pipeline config $config..."
      sed -i "s/#password \=>.*$/password \=> \'${ELASTIC_PASSWORD}\'/g" ${config}
  done

  # *********** Check if Elasticsearch is up ***************
  echo "[HELK-LOGSTASH-DOCKER-INSTALLATION-INFO] Waiting for elasticsearch URI to be accessible.."
  until curl -s -u $ELASTIC_USERNAME:$ELASTIC_PASSWORD $ELASTICSEARCH_URL -o /dev/null; do
    sleep 1
  done

else
  # *********** Check if Elasticsearch is up ***************
  echo "[HELK-LOGSTASH-DOCKER-INSTALLATION-INFO] Waiting for elasticsearch URI to be accessible.."
  until curl -s $ELASTICSEARCH_URL -o /dev/null; do
      sleep 1
  done

fi

# ********** Uploading templates to Elasticsearch *******
echo "[HELK-LOGSTASH-DOCKER-INSTALLATION-INFO] Uploading templates to elasticsearch.."
for file in ${DIR}/*.json; do
    template_name=$(echo $file | sed -r ' s/^.*\/[0-9]+\-//')
    while true; do
      echo "[HELK-LOGSTASH-DOCKER-INSTALLATION-INFO] Uploading $template_name template to elasticsearch.."
      if [[ -n "$ELASTIC_PASSWORD" ]]; then
        STATUS=$(curl -s -o /dev/null -w '%{http_code}' -u $ELASTIC_USERNAME:$ELASTIC_PASSWORD $ELASTICSEARCH_URL)
        if [ $STATUS -eq 200 ]; then
          curl -u $ELASTIC_USERNAME:$ELASTIC_PASSWORD -X POST $ELASTICSEARCH_URL/_template/$template_name -H 'Content-Type: application/json' -d@${file}
          break
        else
          sleep 1
        fi
      else
        STATUS=$(curl -s -o /dev/null -w '%{http_code}' $ELASTICSEARCH_URL)
        if [ $STATUS -eq 200 ]; then
          curl -X POST $ELASTICSEARCH_URL/_template/$template_name -H 'Content-Type: application/json' -d@${file}
          break
        else
          sleep 1
        fi
      fi
    done
done

# ********* Setting LS_JAVA_OPTS ***************
if [[ -z "$LS_JAVA_OPTS" ]]; then
    LS_MEMORY=$(awk '/MemAvailable/{printf "%.f", $2/1024/4}' /proc/meminfo)
    export LS_JAVA_OPTS="-Xms${LS_MEMORY}m -Xmx${LS_MEMORY}m"
fi
echo "[HELK-LOGSTASH-DOCKER-INSTALLATION-INFO] Setting LS_JAVA_OPTS to $LS_JAVA_OPTS"

# ********** Install Plugin *****************
echo "[HELK-LOGSTASH-DOCKER-INSTALLATION-INFO] Installing Logstash plugins.."
if logstash-plugin list 'prune'; then
    echo "[HELK-LOGSTASH-DOCKER-INSTALLATION-INFO] Plugin Prune is already installed"
else
    logstash-plugin install logstash-filter-prune
fi

# ********** Starting Logstash *****************
echo "[HELK-LOGSTASH-DOCKER-INSTALLATION-INFO] Running docker-entrypoint script.."
/usr/local/bin/docker-entrypoint