#!/bin/bash

# HELK script: kibana-setup.sh
# HELK script description: Checks to make sure Kibana starts correctly, runs other scripts such as setting up objects and index patterns, and the basic settings
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g), Nate Guagenti (@neu5ron)
# License: GPL-3.0

# *********** Helk log tagging variables ***************
# For more efficient script editing/reading, and also if/when we switch to different install script language
TAG_NAME="SETUP"
HELK_INFO_TAG="HELK-KIBANA-DOCKER-$TAG_NAME-INFO:"
HELK_ERROR_TAG="HELK-KIBANA-DOCKER-$TAG_NAME-ERROR:"

# *********** Wait for Kibana port to be up ***************
until curl --silent "${KIBANA_ACCESS}" --output /dev/null; do
    echo "$HELK_INFO_TAG Waiting for Kibana internal port to be up.."
    sleep 5
done
echo "$HELK_INFO_TAG Kibana internal port is up.."

# *********** Wait for Elasticsearch Kibana Index to be yellow/green ***************
echo "$HELK_INFO_TAG Checking elasticsearch '.kibana' index"
until [ "$(curl -s -o /dev/null -w '%{http_code}' -X GET -u "${ELASTICSEARCH_CREDS}" "${ELASTICSEARCH_HOSTS}/_cluster/health/.kibana?level=shards?wait_for_status=yellow")" = "200" ]; do
  echo "$HELK_INFO_TAG Waiting for elasticsearch '.kibana' index to start.."
  sleep 5
done
echo "$HELK_INFO_TAG Elasticsearch '.kibana' index is up.."

# *********** Wait for Kibana server to be running ***************
until [[ "$(curl -s -o /dev/null -w "%{http_code}" "${KIBANA_ACCESS}/status")" == "200" ]]; do
  echo "$HELK_INFO_TAG Waiting for kibana server.."
  sleep 2
done
echo "$HELK_INFO_TAG Kibana server is up."

# *********** Importing saved objetcs into Kibana ***************
echo "$HELK_INFO_TAG Importing all the saved objects..."
/usr/share/kibana/scripts/kibana-import-objects.sh

# *********** Set URL session store *********************
echo "$HELK_INFO_TAG Setting URL session store"
curl -X POST -u "${ELASTICSEARCH_CREDS}" "$KIBANA_HOST/api/kibana/settings" -H 'Content-Type: application/json' -H 'kbn-xsrf: true' -d"
{
  \"changes\":{
      \"state:storeInSessionStorage\": true
    }
}
"

# ******** Set Elastic License Variables ***************
if [[ -n "$ELASTICSEARCH_PASSWORD" ]] && [[ -n "$ELASTICSEARCH_USERNAME" ]]; then
  # *********** Creating HELK User *********************
  echo "$HELK_INFO_TAG Setting HELK's user password to $KIBANA_UI_PASSWORD"
  curl -X POST -s -o /dev/null -u "${ELASTICSEARCH_CREDS}" "${ELASTICSEARCH_HOSTS}/_security/user/helk" -H 'Content-Type: application/json' -d"
  {
    \"password\" : \"$KIBANA_UI_PASSWORD\",
    \"roles\" : [ \"superuser\" ],
    \"full_name\" : \"The HELK\",
    \"email\" : \"helk@example.com\"
  }
  "

  # *********** Create Roles *******************
  curl -X POST -s -o /dev/null -u "${ELASTICSEARCH_CREDS}" "${ELASTICSEARCH_HOSTS}/_security/role/hunters" -H 'Content-Type: application/json' -d'
  {
    "run_as": [],
    "cluster": [],
    "indices": [
      {
        "names": [ "logs-*" ],
        "privileges": [ "read" ]
      }
    ]
  }
  '
  curl -X POST -u "${ELASTICSEARCH_CREDS}" "${ELASTICSEARCH_HOSTS}/_security/role/sysmon_hunters" -H 'Content-Type: application/json' -d'
  {
    "run_as": [],
    "cluster": [],
    "indices": [
      {
        "names": [ "logs-endpoint-winevent-sysmon-*" ],
        "privileges": [ "read" ]
      }
    ]
  }
  '
fi

# ******** Modifiying Kibana Interface - HELK Logo **********
#echo "[+++] Updating Kibana Logo..."
#cp -i /usr/share/kibana/custom/HELK.png /usr/share/kibana/optimize/bundles/HELK.png
#cp -i /usr/share/kibana/optimize/bundles/commons.style.css /usr/share/kibana/optimize/bundles/commons.style.css_backup
#cp -i /usr/share/kibana/custom/commons.style.css /usr/share/kibana/optimize/bundles/commons.style.css
