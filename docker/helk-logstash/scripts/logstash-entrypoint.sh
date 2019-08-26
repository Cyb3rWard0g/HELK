#!/bin/bash

# HELK script: logstash-entrypoint.sh
# HELK script description: Pushes output templates to ES and starts Logstash
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# *********** Helk log tagging variables ***************
# For more efficient script editing/reading, and also if/when we switch to different install script language
HELK_LOGSTASH_INFO_TAG="[HELK-LOGSTASH-DOCKER-INSTALLATION-INFO]"
HELK_ERROR_TAG="[HELK-LOGSTASH-DOCKER-INSTALLATION-ERROR]"

# *********** Environment Variables ***************
DIR=/usr/share/logstash/output_templates

if [[ -z "$ES_HOST" ]]; then
  ES_HOST=helk-elasticsearch
fi
echo "$HELK_LOGSTASH_INFO_TAG Setting Elasticsearch server name to $ES_HOST"

if [[ -z "$ES_PORT" ]]; then
  ES_PORT=9200
fi
echo "$HELK_LOGSTASH_INFO_TAG Setting Elasticsearch server port to $ES_PORT"

if [[ -n "$ELASTIC_PASSWORD" ]]; then
  if [[ -z "$ELASTIC_USERNAME" ]]; then
      ELASTIC_USERNAME=elastic
  fi
  echo "$HELK_LOGSTASH_INFO_TAG Setting Elasticsearch username to $ELASTIC_USERNAME"
  ELASTICSEARCH_ACCESS=http://$ELASTIC_USERNAME:"${ELASTIC_PASSWORD}"@$ES_HOST:$ES_PORT
else
  ELASTICSEARCH_ACCESS=http://$ES_HOST:$ES_PORT
fi

CLUSTER_SETTINGS='
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
}
'
# ******** Set Trial License Variables ***************
if [[ -n "$ELASTIC_PASSWORD" ]]; then
  # ****** Updating Pipeline configs ***********
  for config in /usr/share/logstash/pipeline/*-output.conf
  do
      echo "$HELK_LOGSTASH_INFO_TAG Updating pipeline config $config..."
      sed -i "s/#password \=>.*$/password \=> \'${ELASTIC_PASSWORD}\'/g" ${config}
  done
fi

# *********** Check if Elasticsearch is up ***************
until [[ "$(curl -s -o /dev/null -w "%{http_code}" $ELASTICSEARCH_ACCESS)" == "200" ]]; do
    echo "$HELK_LOGSTASH_INFO_TAG Waiting for elasticsearch URI to be accessible.."
    sleep 3
done

# ********** Uploading templates to Elasticsearch *******
echo "$HELK_LOGSTASH_INFO_TAG Uploading templates to elasticsearch.."
for file in ${DIR}/*.json; do
    template_name=$(echo $file | sed -r ' s/^.*\/[0-9]+\-//')
    echo "$HELK_LOGSTASH_INFO_TAG Uploading $template_name template to elasticsearch.."
    until [[ "$(curl -s -o /dev/null -w '%{http_code}' -X POST $ELASTICSEARCH_ACCESS/_template/$template_name -d@${file} -H 'Content-Type: application/json')" == "200" ]]; do
      echo "$HELK_LOGSTASH_INFO_TAG Retrying uploading $template_name"
      sleep 2
    done
done

# ******** Cluster Settings ***************
echo "[HELK-ES-DOCKER-INSTALLATION-INFO] Configuring elasticsearch cluster settings.."
until [[ "$(curl -s -o /dev/null -w '%{http_code}' -X PUT $ELASTICSEARCH_ACCESS/_cluster/settings -H 'Content-Type: application/json' -d "$CLUSTER_SETTINGS")" == "200" ]]; do
  echo "$HELK_LOGSTASH_INFO_TAG Retrying uploading $template_name"
  sleep 2
done

# ********** Install Plugins *****************
echo "$HELK_LOGSTASH_INFO_TAG Checking Logstash plugins.."
# Test a few to determine if probably all already installed
if ( logstash-plugin list 'prune' ) && ( logstash-plugin list 'i18n' ) && ( logstash-plugin list 'wmi' ); then
    echo "$HELK_LOGSTASH_INFO_TAG Plugins are already installed"
else
# logstash-plugin install logstash-filter-dns && logstash-plugin install logstash-filter-cidr && logstash-plugin install logstash-input-lumberjack && logstash-plugin install logstash-output-lumberjack && logstash-plugin install logstash-output-zabbix && logstash-plugin install logstash-filter-geoip && logstash-plugin install logstash-codec-cef && logstash-plugin install logstash-output-syslog && logstash-filter-dissect && logstash-plugin install logstash-output-kafka && logstash-plugin install logstash-input-kafka && logstash-plugin install logstash-filter-translate && logstash-plugin install logstash-filter-alter && logstash-plugin install logstash-filter-fingerprint && logstash-plugin install logstash-output-stdout && logstash-plugin install logstash-filter-prune && logstash-plugin install logstash-codec-gzip_lines && logstash-plugin install logstash-codec-avro && logstash-plugin install logstash-codec-netflow && logstash-plugin install logstash-filter-i18n && logstash-plugin install logstash-filter-environment && logstash-plugin install logstash-filter-de_dot && logstash-plugin install logstash-input-snmptrap && logstash-plugin install logstash-input-snmp && logstash-plugin install logstash-input-jdbc && logstash-plugin install logstash-input-wmi && logstash-plugin install logstash-filter-clone && logstash-plugin update
	if (logstash-plugin install file:///usr/share/logstash/plugins/logstash-offline-plugins-7.3.0.zip); then
    echo "$HELK_LOGSTASH_INFO_TAG Logstash plugins installed via offline package.."
  else
    echo "$HELK_LOGSTASH_INFO_TAG Trying to install logstash plugins over the Internet.."
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
      LS_MEMORY="$(( AVAILABLE_MEMORY / 4 ))m"
      LS_MEMORY_HIGH="$(( AVAILABLE_MEMORY / 2 ))m"
      if [ $AVAILABLE_MEMORY -gt 31000 ]; then
        LS_MEMORY="8000m"
        LS_MEMORY_HIGH="31000m"
      fi
    else
      echo "$HELK_LOGSTASH_INFO_TAG $LS_MEMORY MB is not enough memory for Logstash yet.."
      sleep 1
    fi
    export LS_JAVA_OPTS="${HELK_LOGSTASH_JAVA_OPTS} -Xms${LS_MEMORY} -Xmx${LS_MEMORY_HIGH} "
    break
  done
fi
echo "$HELK_LOGSTASH_INFO_TAG Setting LS_JAVA_OPTS to $LS_JAVA_OPTS"

# ********** Starting Logstash *****************
echo "$HELK_LOGSTASH_INFO_TAG Running docker-entrypoint script.."
/usr/local/bin/docker-entrypoint