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

# ******** Cluster Settings ***************
echo "[HELK-ES-DOCKER-INSTALLATION-INFO] Configuring elasticsearch cluster settings.."
while true; do
  if [[ -n "$ELASTIC_PASSWORD" ]]; then
    STATUS=$(curl -s -o /dev/null -w '%{http_code}' -u $ELASTIC_USERNAME:$ELASTIC_PASSWORD $ELASTICSEARCH_URL)
    if [ $STATUS -eq 200 ]; then
      curl -u $ELASTIC_USERNAME:$ELASTIC_PASSWORD -XPUT $ELASTICSEARCH_URL/_cluster/settings -H 'Content-Type: application/json' -d'
        {
          "persistent": {
            "search.max_open_scroll_context": 15000,
            "indices.breaker.request.limit" : "70%"
          },
          "transient": {
            "search.max_open_scroll_context": 15000,
            "indices.breaker.request.limit" : "70%"
          }
        }'
      break
    else
      sleep 1
    fi
  else
    STATUS=$(curl -s -o /dev/null -w '%{http_code}' $ELASTICSEARCH_URL)
    if [ $STATUS -eq 200 ]; then
      curl -XPUT $ELASTICSEARCH_URL/_cluster/settings -H 'Content-Type: application/json' -d'
        {
          "persistent": {
            "search.max_open_scroll_context": 15000,
            "indices.breaker.request.limit" : "70%",
            "cluster.max_shards_per_node": 3000
          },
          "transient": {
            "search.max_open_scroll_context": 15000,
            "indices.breaker.request.limit" : "70%",
            "cluster.max_shards_per_node": 3000
          }
        }'
      break
    else
      sleep 1
    fi
  fi
done

# ********** Install Plugins *****************
echo "[HELK-LOGSTASH-DOCKER-INSTALLATION-INFO] Checking Logstash plugins.."
# Test a few to determine if probably all already installed
if ( logstash-plugin list 'prune' ) && ( logstash-plugin list 'i18n' ) && ( logstash-plugin list 'wmi' ); then
    echo "[HELK-LOGSTASH-DOCKER-INSTALLATION-INFO] Plugins are already installed"
else
# logstash-plugin install logstash-filter-dns && logstash-plugin install logstash-filter-cidr && logstash-plugin install logstash-input-lumberjack && logstash-plugin install logstash-output-lumberjack && logstash-plugin install logstash-output-zabbix && logstash-plugin install logstash-filter-geoip && logstash-plugin install logstash-codec-cef && logstash-plugin install logstash-output-syslog && logstash-filter-dissect && logstash-plugin install logstash-output-kafka && logstash-plugin install logstash-input-kafka && logstash-plugin install logstash-filter-translate && logstash-plugin install logstash-filter-alter && logstash-plugin install logstash-filter-fingerprint && logstash-plugin install logstash-output-stdout && logstash-plugin install logstash-filter-prune && logstash-plugin install logstash-codec-gzip_lines && logstash-plugin install logstash-codec-avro && logstash-plugin install logstash-codec-netflow && logstash-plugin install logstash-filter-i18n && logstash-plugin install logstash-filter-environment && logstash-plugin install logstash-filter-de_dot && logstash-plugin install logstash-input-snmptrap && logstash-plugin install logstash-input-snmp && logstash-plugin install logstash-input-jdbc && logstash-plugin install logstash-input-wmi && logstash-plugin install logstash-filter-clone && logstash-plugin update
	if (logstash-plugin install file:///usr/share/logstash/plugins/logstash-offline-plugins-7.3.0.zip); then
    echo "[HELK-LOGSTASH-DOCKER-INSTALLATION-INFO] Logstash plugins installed via offline package.."
  else
    echo "[HELK-LOGSTASH-DOCKER-INSTALLATION-INFO] Trying to install logstash plugins over the Internet.."
    logstash-plugin install logstash-filter-translate && logstash-plugin install logstash-filter-dns && logstash-plugin install logstash-filter-cidr && logstash-plugin install logstash-filter-geoip && logstash-plugin update logstash-filter-dissect && logstash-plugin install logstash-output-kafka && logstash-plugin install logstash-input-kafka && logstash-plugin install logstash-filter-alter && logstash-plugin install logstash-filter-fingerprint && logstash-plugin install logstash-filter-prune && logstash-plugin install logstash-codec-gzip_lines && logstash-plugin install logstash-codec-netflow && logstash-plugin install logstash-filter-i18n && logstash-plugin install logstash-filter-environment && logstash-plugin install logstash-filter-de_dot && logstash-plugin install logstash-input-wmi && logstash-plugin install logstash-filter-clone && logstash-plugin update
  fi
fi

# ********* Setting LS_JAVA_OPTS ***************
if [[ -z "$LS_JAVA_OPTS" ]]; then
  while true; do
    # Check using more accurate MB
    AVAILABLE_MEMORY=$(awk '/MemAvailable/{printf "%.f", $2/1024}' /proc/meminfo)
    if [ $AVAILABLE_MEMORY -ge 900 -a $AVAILABLE_MEMORY -le 1000 ]; then
      LS_MEMORY="400m"
      LS_MEMORY_HIGH="1000m"
    elif [ $AVAILABLE_MEMORY -ge 1001 -a $AVAILABLE_MEMORY -le 3000 ]; then
      LS_MEMORY="700m"
      LS_MEMORY_HIGH="1300m"
    elif [ $AVAILABLE_MEMORY -gt 3000 ]; then
      # Set high & low, so logstash doesn't use everything unnecessarily, it will usually flux up and down in usage -- and doesn't "severely" despite what everyone seems to believe
      LS_MEMORY=$(( AVAILABLE_MEMORY / 4 ))
      LS_MEMORY_HIGH=$(( AVAILABLE_MEMORY / 2 ))
      if [ $AVAILABLE_MEMORY -gt 31000 ]; then
        LS_MEMORY="8000m"
        LS_MEMORY_HIGH="31000m"
      fi
    else
      echo "[HELK-LOGSTASH-DOCKER-INSTALLATION-INFO] $LS_MEMORY MB is not enough memory for Logstash yet.."
      sleep 1
    fi
    export LS_JAVA_OPTS="${HELK_LOGSTASH_JAVA_OPTS} -Xms${LS_MEMORY} -Xmx${LS_MEMORY_HIGH} "
    break
  done
fi
echo "[HELK-LOGSTASH-DOCKER-INSTALLATION-INFO] Setting LS_JAVA_OPTS to $LS_JAVA_OPTS"

# ********** Starting Logstash *****************
echo "[HELK-LOGSTASH-DOCKER-INSTALLATION-INFO] Running docker-entrypoint script.."
/usr/local/bin/docker-entrypoint