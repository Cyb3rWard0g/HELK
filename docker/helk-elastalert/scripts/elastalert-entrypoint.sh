#!/bin/bash

# HELK script: elastalert-entryppoint.sh
# HELK script description: Creates Elastalert index
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# *********** Helk log tagging variables ***************
# For more efficient script editing/reading, and also if/when we switch to different install script language
HELK_ELASTALERT_INFO_TAG="$HELK_ELASTALERT_INFO_TAG"
#HELK_ERROR_TAG="[HELK-ELASTALERT-DOCKER-INSTALLATION-ERROR]"

# *********** Environment Variables***************
if [[ -z "$ES_HOST" ]]; then
  ES_HOST=helk-elasticsearch
fi
echo "$HELK_ELASTALERT_INFO_TAG Setting Elasticsearch server name to $ES_HOST"

if [[ -z "$ES_PORT" ]]; then
  ES_PORT=9200
fi
echo "$HELK_ELASTALERT_INFO_TAG Setting Elasticsearch server port to $ES_PORT"

if [[ -n "$ELASTIC_PASSWORD" ]]; then
    if [[ -z "$ELASTIC_USERNAME" ]]; then
        ELASTIC_USERNAME=elastic
    fi
    echo "es_username: $ELASTIC_USERNAME" >> "${ESALERT_HOME}/config.yaml"
    echo "es_password: $ELASTIC_PASSWORD" >> "${ESALERT_HOME}/config.yaml"
    echo "$HELK_ELASTALERT_INFO_TAG Setting Elasticsearch username to $ELASTIC_USERNAME"
    echo "$HELK_ELASTALERT_INFO_TAG Setting Elasticsearch password to $ELASTIC_PASSWORD"
    ELASTICSEARCH_ACCESS=http://$ELASTIC_USERNAME:"$ELASTIC_PASSWORD"@$ES_HOST:$ES_PORT
else
    ELASTICSEARCH_ACCESS=http://$ES_HOST:$ES_PORT
fi

# *********** Update Elastalert Config ******************
echo "$HELK_ELASTALERT_INFO_TAG Updating Elastalert main config.."
sed -i "s/^es_host\:.*$/es_host\: ${ES_HOST}/g" "${ESALERT_HOME}/config.yaml"
sed -i "s/^es_port\:.*$/es_port\: ${ES_PORT}/g" "${ESALERT_HOME}/config.yaml"

# *********** Check if Elasticsearch is up ***************
until [[ "$(curl -s -o /dev/null -w "%{http_code}" $ELASTICSEARCH_ACCESS)" == "200" ]]; do
    echo "$HELK_ELASTALERT_INFO_TAG Waiting for elasticsearch URI to be accessible.."
    sleep 3
done

# *********** Transform SIGMA Rules to Elastalert Signatures *************
echo "$HELK_ELASTALERT_INFO_TAG Executing pull-sigma.sh script.."
/etc/elastalert/pull-sigma.sh

# *********** Creating Elastalert Status Index ***************
response_code=$(curl -s -o /dev/null -w "%{http_code}" $ELASTICSEARCH_ACCESS/elastalert_status)
if [[ $response_code == 404 ]]; then
    echo "$HELK_ELASTALERT_INFO_TAG Creating Elastalert index.."
    if [[ -n "$ELASTIC_PASSWORD" ]]; then
        elastalert-create-index --host $ES_HOST --port $ES_PORT --username $ELASTIC_USERNAME --password "$ELASTIC_PASSWORD" --no-auth --no-ssl --url-prefix '' --old-index ''
    else
        elastalert-create-index --host $ES_HOST --port $ES_PORT --no-auth --no-ssl --url-prefix '' --old-index ''
    fi
else
    echo "$HELK_ELASTALERT_INFO_TAG Elastalert index already exists"
fi

# *********** Setting Slack Integration *************
rule_counter=0
if [[ "$SLACK_WEBHOOK_URL" ]]; then
    echo "$HELK_ELASTALERT_INFO_TAG Setting Slack webhook url to ${SLACK_WEBHOOK_URL}.."
    for er in "${ESALERT_HOME}"/rules/*; do
        priority=$(sed -n -e 's/^priority: //p' "$er")
        if [[ $priority = "1" ]]; then
            if grep -q '^- slack$' "$er"; then
                SLACK_WEBHOOK_CURRENT=$(sed -n -e 's/^slack_webhook_url: //p' "$er")
                if [[ $SLACK_WEBHOOK_CURRENT == "${SLACK_WEBHOOK_URL}" ]]; then
                    echo "[+++] Slack Webhook URL provided has been already applied to rule $er"
                else
                    echo "[+++] Updating slack webhook url from $SLACK_WEBHOOK_CURRENT to $SLACK_WEBHOOK_URL"
                    sed -i "s,^slack_webhook_url\:.*$,slack_webhook_url\: ${SLACK_WEBHOOK_URL},g" "$er"
                fi
            else
                echo "[+++] Adding slack webhook url $SLACK_WEBHOOK_URL to rule $er"
                sed -i "s/^- debug$/- slack/g" "$er"
                sed -i "/- slack/a slack_webhook_url: $SLACK_WEBHOOK_URL" "$er"
            fi
            rule_counter=$[$rule_counter +1]
        fi
    done
    echo "------------------------------------------------------------------------------------"
    echo "[+++] Finished processing Slack Webhook URL info on $rule_counter Elastalert rules"
    echo "------------------------------------------------------------------------------------"
    echo " "
fi

echo "$HELK_ELASTALERT_INFO_TAG Starting Elastalert.."
exec "$@"