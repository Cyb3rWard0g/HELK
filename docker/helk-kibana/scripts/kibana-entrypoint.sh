#!/bin/sh

# HELK script: kibana-entrypoint.sh
# HELK script description: Starts Kibana service
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# *********** Helk log tagging variables ***************
# For more efficient script editing/reading, and also if/when we switch to different install script language
TAG_NAME="ENTRYPOINT"
HELK_INFO_TAG="HELK-KIBANA-DOCKER-$TAG_NAME-INFO:"
HELK_ERROR_TAG="HELK-KIBANA-DOCKER-$TAG_NAME-ERROR:"

# *********** Install Plugins *********************

# *********** Environment Variables ***************
if [[ -z "$ELASTICSEARCH_HOSTS" ]]; then
  export ELASTICSEARCH_HOSTS=http://helk-elasticsearch:9200
fi
echo "$HELK_INFO_TAG Setting Elasticsearch URL to $ELASTICSEARCH_HOSTS"

if [[ -z "$SERVER_HOST" ]]; then
  export SERVER_HOST=helk-kibana
fi
echo "$HELK_INFO_TAG Setting Kibana server to $SERVER_HOST"

if [[ -z "$SERVER_PORT" ]]; then
  export SERVER_PORT=5601
fi
echo "$HELK_INFO_TAG Setting Kibana server port to $SERVER_PORT"

# ******** Set Trial License Variables ***************
if [[ -n "$ELASTICSEARCH_PASSWORD" ]]; then
  if [[ -z "$ELASTICSEARCH_USERNAME" ]]; then
    export ELASTICSEARCH_USERNAME=elastic
  fi
  echo "$HELK_INFO_TAG Setting Elasticsearch's username to access Elasticsearch to $ELASTICSEARCH_USERNAME"

  if [[ -z "$KIBANA_USER" ]]; then
    export KIBANA_USER=kibana
  fi
  echo "$HELK_INFO_TAG Setting Kibana's username to access Elasticsearch to $KIBANA_USER"

  if [[ -z "$KIBANA_PASSWORD" ]]; then
    export KIBANA_PASSWORD=kibanapassword
  fi
  echo "$HELK_INFO_TAG Setting Kibana's password to access Elasticsearch to $KIBANA_PASSWORD"

  if [[ -z "$KIBANA_UI_PASSWORD" ]]; then
    export KIBANA_UI_PASSWORD=hunting
  fi
  echo "$HELK_INFO_TAG Setting Kibana's UI password to $KIBANA_UI_PASSWORD"

  # *********** Check if Elasticsearch is up ***************
  #echo "$HELK_INFO_TAG Waiting for elasticsearch URI to be accessible.."
  until [[ "$(curl -s -o /dev/null -w "%{http_code}" -u $ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD $ELASTICSEARCH_HOSTS)" == "200" ]]; do
    echo "$HELK_INFO_TAG Waiting for elasticsearch URI to be accessible.."
    sleep 5
  done
  sleep 5

  # *********** Change Kibana and Logstash password ***************
  echo "$HELK_INFO_TAG Submitting a request to change the password of a Kibana and Logstash users .."
  until curl -u $ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD -H 'Content-Type:application/json' -XPUT $ELASTICSEARCH_HOSTS/_security/user/kibana/_password -d "{\"password\": \"$KIBANA_PASSWORD\"}"
  do
    sleep 1
  done

  until curl -u $ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD -H 'Content-Type:application/json' -XPUT $ELASTICSEARCH_HOSTS/_security/user/logstash_system/_password -d "{\"password\": \"logstashpassword\"}"
  do
    sleep 1
  done

else
  # *********** Check if Elasticsearch is up ***************
  #echo "$HELK_INFO_TAG Waiting for elasticsearch URI to be accessible.."
  until [[ "$(curl -s -o /dev/null -w "%{http_code}" $ELASTICSEARCH_HOSTS)" == "200" ]]; do
    echo "$HELK_INFO_TAG Waiting for elasticsearch URI to be accessible.."
    sleep 5
  done
  sleep 5
fi

echo "$HELK_INFO_TAG Starting Kibana service.."
exec /usr/local/bin/kibana-docker &

# *********** Creating Kibana Dashboards, visualizations and index-patterns ***************
echo "$HELK_INFO_TAG Running helk_kibana_setup.sh script..."
/usr/share/kibana/scripts/kibana-setup.sh

tail -f /usr/share/kibana/config/kibana_logs.log