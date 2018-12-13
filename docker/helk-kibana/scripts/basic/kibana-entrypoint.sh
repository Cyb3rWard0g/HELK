#!/bin/sh

# HELK script: kibana-entrypoint.sh
# HELK script description: Starts Kibana service
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# *********** Install Plugins *********************

# *********** Environment Variables ***************
if [[ -z "$ELASTICSEARCH_URL" ]]; then
    export ELASTICSEARCH_URL="http://helk-elasticsearch:9200"
fi
echo "[HELK-ES-DOCKER-INSTALLATION-INFO] Setting Elasticsearch URL to $ELASTICSEARCH_URL"

if [[ -z "$SERVER_HOST" ]]; then
    export SERVER_HOST="helk-kibana"
fi
echo "[HELK-ES-DOCKER-INSTALLATION-INFO] Setting Kibana server host to $SERVER_HOST"

if [[ -z "$SERVER_PORT" ]]; then
    export SERVER_PORT="5601"
fi
echo "[HELK-ES-DOCKER-INSTALLATION-INFO] Setting Kibana server port to $SERVER_PORT"


# *********** Start Kibana services ***************
echo "[HELK-DOCKER-INSTALLATION-INFO] Waiting for elasticsearch URI to be accessible.."
until curl -s $ELASTICSEARCH_URL -o /dev/null; do
    sleep 1
done

echo "[HELK-DOCKER-INSTALLATION-INFO] Starting Kibana service.."
exec /usr/local/bin/kibana-docker &

# *********** Creating Kibana Dashboards, visualizations and index-patterns ***************
echo "[HELK-DOCKER-INSTALLATION-INFO] Running helk_kibana_setup.sh script..."
/usr/share/kibana/scripts/kibana-setup.sh

tail -f /usr/share/kibana/config/kibana_logs.log