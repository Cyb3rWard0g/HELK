#!/bin/bash

# HELK script: elastalert-entryppoint.sh
# HELK script description: Creates Elastalert index
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0
# Reference:
# https://github.com/Yelp/elastalert/issues/211

# *********** Environment Variables***************
if [[ -z "$ES_HOST" ]]; then
  ES_HOST=helk-elasticsearch
fi
echo "[HELK-ELASTALERT-DOCKER-INSTALLATION-INFO] Setting Elasticsearch server name to $ES_HOST"

if [[ -z "$ES_PORT" ]]; then
  ES_PORT=9200
fi
echo "[HELK-ELASTALERT-DOCKER-INSTALLATION-INFO] Setting Elasticsearch server port to $ES_PORT"

if [[ -n "$ELASTIC_PASSWORD" ]]; then
    if [[ -z "$ELASTIC_USERNAME" ]]; then
        ELASTIC_USERNAME=elastic
    fi
    echo "es_username: $ELASTIC_USERNAME" >> $ESALERT_HOME/config.yaml
    echo "es_password: $ELASTIC_PASSWORD" >> $ESALERT_HOME/config.yaml
    echo "[HELK-ELASTALERT-DOCKER-INSTALLATION-INFO] Setting Elasticsearch username to $ELASTIC_USERNAME"
    echo "[HELK-ELASTALERT-DOCKER-INSTALLATION-INFO] Setting Elasticsearch password to $ELASTIC_PASSWORD"
    ELASTICSEARCH_ACCESS=http://$ELASTIC_USERNAME:"$ELASTIC_PASSWORD"@$ES_HOST:$ES_PORT
else
    ELASTICSEARCH_ACCESS=http://$ES_HOST:$ES_PORT
fi

# *********** Update Elastalert Config ******************
echo "[HELK-ELASTALERT-DOCKER-INSTALLATION-INFO] Updating Elastalert main config.."
sed -i "s/^es_host\:.*$/es_host\: ${ES_HOST}/g" $ESALERT_HOME/config.yaml
sed -i "s/^es_port\:.*$/es_port\: ${ES_PORT}/g" $ESALERT_HOME/config.yaml

# *********** Check if Elasticsearch is up ***************
echo "[HELK-ELASTALERT-DOCKER-INSTALLATION-INFO] Waiting for elasticsearch URI to be accessible.."
until curl -s $ES_HOST:$ES_PORT -o /dev/null; do
    sleep 1
done

# *********** Creating Elastalert Status Index ***************
response_code=$(curl -s -o /dev/null -w "%{http_code}" $ELASTICSEARCH_ACCESS/elastalert_status)
if [[ $response_code == 404 ]]; then
    echo "[HELK-ELASTALERT-DOCKER-INSTALLATION-INFO] Creating Elastalert index.."
    if [[ -n "$ELASTIC_PASSWORD" ]]; then
        elastalert-create-index --host $ES_HOST --port $ES_PORT --username $ELASTIC_USERNAME --password $ELASTIC_PASSWORD --no-auth --no-ssl --url-prefix '' --old-index ''
    else
        elastalert-create-index --host $ES_HOST --port $ES_PORT --no-auth --no-ssl --url-prefix '' --old-index ''
    fi
else
    echo "[HELK-ELASTALERT-DOCKER-INSTALLATION-INFO] Elastalert index already exists"
fi

# *********** Transform SIGMA Rules to Elastalert Signatures *************
echo "[HELK-ELASTALERT-DOCKER-INSTALLATION-INFO] Executing pull-sigma.sh script.."
/etc/elastalert/pull-sigma.sh

# *********** Setting Slack Integration *************
rule_counter=0
if [[ "$SLACK_WEBHOOK_URL" ]]; then
    echo "[HELK-ELASTALERT-DOCKER-INSTALLATION-INFO] Setting Slack webhook url to $SLACK_WEBHOOK_URL.."
    for er in $ESALERT_HOME/rules/*; do
        priority=$(sed -n -e 's/^priority: //p' $er)
        if [[ $priority = "1" ]]; then
            if grep -q '^- slack$' $er; then
                SLACK_WEBHOOK_CURRENT=$(sed -n -e 's/^slack_webhook_url: //p' $er)
                if [[ $SLACK_WEBHOOK_CURRENT == $SLACK_WEBHOOK_URL ]]; then
                    echo "[+++] Slack Webhook URL provided has been already applied to rule $er"
                else
                    echo "[+++] Updating slack webhook url from $SLACK_WEBHOOK_CURRENT to $SLACK_WEBHOOK_URL"
                    sed -i "s,^slack_webhook_url\:.*$,slack_webhook_url\: ${SLACK_WEBHOOK_URL},g" $er
                fi
            else
                echo "[+++] Adding slack webhook url $SLACK_WEBHOOK_URL to rule $er"
                sed -i "s/^- debug$/- slack/g" $er
                sed -i "/- slack/a slack_webhook_url: $SLACK_WEBHOOK_URL" $er
            fi
            rule_counter=$[$rule_counter +1]
        fi
    done
    echo "------------------------------------------------------------------------------------"
    echo "[+++] Finished processing Slack Webhook URL info on $rule_counter Elastalert rules"
    echo "------------------------------------------------------------------------------------"
    echo " "
fi

echo "[HELK-ELASTALERT-DOCKER-INSTALLATION-INFO] Starting Elastalert.."
exec "$@"