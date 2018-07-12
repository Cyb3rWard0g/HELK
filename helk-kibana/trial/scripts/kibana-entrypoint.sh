#!/bin/sh

# HELK script: kibana-entrypoint.sh
# HELK script description: Starts Kibana service
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

ELASTICSEARCH_ACCESS=http://elastic:"elasticpassword"@helk-elasticsearch:9200

# *********** Check if Elasticsearch is up ***************
echo "[HELK-DOCKER-INSTALLATION-INFO] Waiting for elasticsearch URI to be accessible.."
until curl -s $ELASTICSEARCH_ACCESS -o /dev/null; do
    sleep 1
done

# *********** Check if Elasticsearch is up ***************
echo "[HELK-DOCKER-INSTALLATION-INFO] Submitting a request to change the password of a Kibana and Logstash users .."
until curl -s -H 'Content-Type:application/json' -XPUT $ELASTICSEARCH_ACCESS/_xpack/security/user/kibana/_password -d "{\"password\": \"kibanapassword\"}"
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