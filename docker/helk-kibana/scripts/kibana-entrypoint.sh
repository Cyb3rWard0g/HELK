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
echo "[HELK-KIBANA-DOCKER-INSTALLATION-INFO] Setting Elasticsearch URL to $ELASTICSEARCH_URL"

if [[ -z "$SERVER_HOST" ]]; then
  export SERVER_HOST=helk-kibana
fi
echo "[HELK-KIBANA-DOCKER-INSTALLATION-INFO] Setting Kibana server host to $SERVER_HOST"

if [[ -z "$SERVER_PORT" ]]; then
  export SERVER_PORT=5601
fi
echo "[HELK-KIBANA-DOCKER-INSTALLATION-INFO] Setting Kibana server port to $SERVER_PORT"

# ******** Set Trial License Variables ***************
if [[ -n "$ELASTICSEARCH_PASSWORD" ]]; then
  if [[ -z "$ELASTICSEARCH_USERNAME" ]]; then
    export ELASTICSEARCH_USERNAME=elastic
  fi
  echo "[HELK-KIBANA-DOCKER-INSTALLATION-INFO] Setting Elasticsearch's username to access Elasticsearch to $ELASTICSEARCH_USERNAME"

  if [[ -z "$KIBANA_USER" ]]; then
    export KIBANA_USER=kibana
  fi
  echo "[HELK-KIBANA-DOCKER-INSTALLATION-INFO] Setting Kibana's username to access Elasticsearch to $KIBANA_USER"

  if [[ -z "$KIBANA_PASSWORD" ]]; then
    export KIBANA_PASSWORD=kibanapassword
  fi
  echo "[HELK-KIBANA-DOCKER-INSTALLATION-INFO] Setting Kibana's password to access Elasticsearch to $KIBANA_PASSWORD"

  if [[ -z "$KIBANA_UI_PASSWORD" ]]; then
    export KIBANA_UI_PASSWORD=hunting
  fi
  echo "[HELK-KIBANA-DOCKER-INSTALLATION-INFO] Setting Kibana's UI password to $KIBANA_UI_PASSWORD"

  # *********** Check if Elasticsearch is up ***************
  echo "[HELK-KIBANA-DOCKER-INSTALLATION-INFO] Waiting for elasticsearch URI to be accessible.."
  until curl -s -u $ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD $ELASTICSEARCH_URL -o /dev/null; do
    sleep 1
  done

  # *********** Change Kibana and Logstash password ***************
  echo "[HELK-KIBANA-DOCKER-INSTALLATION-INFO] Submitting a request to change the password of a Kibana and Logstash users .."
  until curl -u $ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD -H 'Content-Type:application/json' -XPUT $ELASTICSEARCH_URL/_xpack/security/user/kibana/_password -d "{\"password\": \"$KIBANA_PASSWORD\"}"
  do
    sleep 1
  done

  until curl -u $ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD -H 'Content-Type:application/json' -XPUT $ELASTICSEARCH_URL/_xpack/security/user/logstash_system/_password -d "{\"password\": \"logstashpassword\"}"
  do
    sleep 1
  done

else
  # *********** Check if Elasticsearch is up ***************
  echo "[HELK-KIBANA-DOCKER-INSTALLATION-INFO] Waiting for elasticsearch URI to be accessible.."
  until curl -s $ELASTICSEARCH_URL -o /dev/null; do
    sleep 1
  done
fi

echo "[HELK-KIBANA-DOCKER-INSTALLATION-INFO] Starting Kibana service.."
exec /usr/local/bin/kibana-docker &

# *********** Creating Kibana Dashboards, visualizations and index-patterns ***************
echo "[HELK-KIBANA-DOCKER-INSTALLATION-INFO] Running helk_kibana_setup.sh script..."
/usr/share/kibana/scripts/kibana-setup.sh

tail -f /usr/share/kibana/config/kibana_logs.log