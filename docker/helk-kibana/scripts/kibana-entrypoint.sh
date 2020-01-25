#!/bin/sh

# HELK script: kibana-entrypoint.sh
# HELK script description: Starts Kibana service
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g), Nate Guagenti (@neu5ron)
# License: GPL-3.0

# *********** Helk log tagging variables ***************
# For more efficient script editing/reading, and also if/when we switch to different install script language
TAG_NAME="ENTRYPOINT"
HELK_INFO_TAG="HELK-KIBANA-DOCKER-$TAG_NAME-INFO:"
HELK_ERROR_TAG="HELK-KIBANA-DOCKER-$TAG_NAME-ERROR:"

# *********** Install Plugins *********************

# *********** Environment Variables ***************
if [ -z "$ELASTICSEARCH_HOSTS" ]; then
  export ELASTICSEARCH_HOSTS=http://helk-elasticsearch:9200
fi
echo "$HELK_INFO_TAG Setting Elasticsearch URL to $ELASTICSEARCH_HOSTS"

if [ -z "$SERVER_HOST" ]; then
  export SERVER_HOST=helk-kibana
fi
echo "$HELK_INFO_TAG Setting Kibana server to $SERVER_HOST"

if [ -z "$SERVER_PORT" ]; then
  export SERVER_PORT=5601
fi
echo "$HELK_INFO_TAG Setting Kibana server port to $SERVER_PORT"

KIBANA_HOST=http://$SERVER_HOST:$SERVER_PORT
echo "$HELK_INFO_TAG Setting Kibana URL to $KIBANA_HOST"

if [ -n "$ELASTICSEARCH_PASSWORD" ]; then
  if [ -z "$ELASTICSEARCH_USERNAME" ]; then
    export ELASTICSEARCH_USERNAME=elastic
  fi
  if [ -z "$KIBANA_USER" ]; then
    export KIBANA_USER=kibana
  fi
  if [ -z "$KIBANA_PASSWORD" ]; then
    export KIBANA_PASSWORD=kibanapassword
  fi
  if [ -z "$KIBANA_UI_PASSWORD" ]; then
    export KIBANA_UI_PASSWORD=hunting
  fi
  export ELASTICSEARCH_CREDS="${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}"
  KIBANA_ACCESS=http://$KIBANA_USER:"$KIBANA_PASSWORD"@$SERVER_HOST:$SERVER_PORT

else
  KIBANA_ACCESS=$KIBANA_HOST
fi
# Do not echo user/password, just set the variable
export KIBANA_ACCESS
export KIBANA_HOST

# *********** Check if Elasticsearch is up ***************
until [ "$(curl -s -o /dev/null -w "%{http_code}"  -u "${ELASTICSEARCH_CREDS}" "${ELASTICSEARCH_HOSTS}")" = "200" ]; do
  echo "$HELK_INFO_TAG Waiting for very basic elasticsearch check.."
  sleep 5
done
sleep 5

# *********** Set Elastic License Variables ***************

if [ -n "$ELASTICSEARCH_PASSWORD" ]; then
  # Check to see if Security index already exists
  # https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-exists.html
  echo "$HELK_INFO_TAG Checking elasticsearch '.security' index found"
  while true
    do
      ES_STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" --head -u "${ELASTICSEARCH_CREDS}" "${ELASTICSEARCH_HOSTS}/.security")
      if [ "$ES_STATUS_CODE" -eq 200 ]; then
        echo "$HELK_INFO_TAG Elasticsearch '.security' index found"
        break
      elif [ "$ES_STATUS_CODE" -eq 404 ]; then
        echo "$HELK_INFO_TAG Elasticsearch '.security' index not found. Submitting requests to create it.."
        break
      fi
      sleep 3
  done

  # *********** Change Kibana and Logstash password ***************
  echo "$HELK_INFO_TAG Submitting a request to change the password of the Kibana user"
  until [ "$(curl -s -o /dev/null -w '%{http_code}' -X POST -u "${ELASTICSEARCH_CREDS}" "${ELASTICSEARCH_HOSTS}/_security/user/kibana/_password" -H 'Content-Type:application/json' -d "{\"password\": \"${KIBANA_PASSWORD}\"}")" = "200" ]; do
    echo "$HELK_INFO_TAG Retrying Kibana user password change.."
    sleep 2
  done

  echo "$HELK_INFO_TAG Submitting a request to change the password of the Logstash user"
  until [ "$(curl -s -o /dev/null -w '%{http_code}' -X POST -u "${ELASTICSEARCH_CREDS}" "${ELASTICSEARCH_HOSTS}/_security/user/logstash_system/_password" -H 'Content-Type:application/json' -d "{\"password\": \"logstashpassword\"}")" = "200" ]; do
    echo "$HELK_INFO_TAG Retrying Logstash user password change.."
    sleep 2
  done
fi

echo "$HELK_INFO_TAG Starting Kibana service.."
exec /usr/local/bin/kibana-docker &

# *********** Creating Kibana Dashboards, visualizations and index-patterns ***************
echo "$HELK_INFO_TAG Running kibana-setup.sh.."
/usr/share/kibana/scripts/kibana-setup.sh

tail -f /usr/share/kibana/config/kibana_logs.log