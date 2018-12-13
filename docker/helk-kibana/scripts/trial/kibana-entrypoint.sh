#!/bin/sh

# HELK script: kibana-entrypoint.sh
# HELK script description: Starts Kibana service
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# *********** Install Plugins *********************

# *********** Environment Variables ***************
if [[ -z "$ELASTICSEARCH_URL" ]]; then
  export ELASTICSEARCH_URL=http://helk-elasticsearch:9200
fi
echo "[HELK-ES-DOCKER-INSTALLATION-INFO] Setting Elasticsearch URL to $ELASTICSEARCH_URL"

if [[ -z "$SERVER_HOST" ]]; then
  export SERVER_HOST=helk-kibana
fi
echo "[HELK-ES-DOCKER-INSTALLATION-INFO] Setting Kibana server host to $SERVER_HOST"

if [[ -z "$SERVER_PORT" ]]; then
  export SERVER_PORT=5601
fi
echo "[HELK-ES-DOCKER-INSTALLATION-INFO] Setting Kibana server port to $SERVER_PORT"

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

# *********** Password used by Kibana to access Elasticsearch ********
if [[ -z "$ELASTICSEARCH_PASSWORD" ]]; then
  export ELASTICSEARCH_PASSWORD=kibanapassword
fi
echo "[HELK-ES-DOCKER-INSTALLATION-INFO] Setting Kibana's password to access Elasticsearch to $ELASTICSEARCH_PASSWORD"

if [[ -z "$ELASTICSEARCH_USERNAME" ]]; then
  export ELASTICSEARCH_USERNAME=kibana
fi
echo "[HELK-ES-DOCKER-INSTALLATION-INFO] Setting Kibana's username to access Elasticsearch to $ELASTICSEARCH_USERNAME"

if [[ -z "$KIBANA_UI_PASSWORD" ]]; then
  KIBANA_UI_PASSWORD=hunting
fi
echo "[HELK-ES-DOCKER-INSTALLATION-INFO] Setting Kibana's UI password to $KIBANA_UI_PASSWORD"

if [[ -z "$ELASTICSEARCH_ACCESS" ]]; then
  ELASTICSEARCH_ACCESS=http://elastic:$ELASTIC_PASSWORD@$ELASTIC_HOST:$ELASTIC_PORT
fi
echo "[HELK-ES-DOCKER-INSTALLATION-INFO] Setting custom ELasticsearch URL with credentials to $ELASTICSEARCH_ACCESS"

# *********** Check if Elasticsearch is up ***************
echo "[HELK-DOCKER-INSTALLATION-INFO] Waiting for elasticsearch URI to be accessible.."
until curl -s $ELASTICSEARCH_URL -o /dev/null; do
    sleep 1
done

# *********** Change Kibana and Logstash password ***************
echo "[HELK-DOCKER-INSTALLATION-INFO] Submitting a request to change the password of a Kibana and Logstash users .."
until curl -s -H 'Content-Type:application/json' -XPUT $ELASTICSEARCH_ACCESS/_xpack/security/user/kibana/_password -d "{\"password\": \"$ELASTICSEARCH_PASSWORD\"}"
do
    sleep 2
done

until curl -s -H 'Content-Type:application/json' -XPUT $ELASTICSEARCH_ACCESS/_xpack/security/user/logstash_system/_password -d "{\"password\": \"logstashpassword\"}"
do
    sleep 2
done

echo "[HELK-DOCKER-INSTALLATION-INFO] Starting Kibana service.."
exec /usr/local/bin/kibana-docker &

# *********** Creating Kibana Dashboards, visualizations and index-patterns ***************
echo "[HELK-DOCKER-INSTALLATION-INFO] Running helk_kibana_setup.sh script..."
/usr/share/kibana/scripts/kibana-setup.sh

tail -f /usr/share/kibana/config/kibana_logs.log