#!/bin/sh

# HELK script: kibana-entrypoint.sh
# HELK script description: Starts Kibana service
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# *********** Start Kibana services ***************
echo "[HELK-DOCKER-INSTALLATION-INFO] Waiting for elasticsearch URI to be accessible.."
until curl -s helk-elasticsearch:9200 -o /dev/null; do
    sleep 1
done

echo "[HELK-DOCKER-INSTALLATION-INFO] Starting Kibana service.."
exec /usr/local/bin/kibana-docker &

# *********** Creating Kibana Dashboards, visualizations and index-patterns ***************
echo "[HELK-DOCKER-INSTALLATION-INFO] Running helk_kibana_setup.sh script..."
/usr/share/kibana/scripts/kibana-setup.sh

tail -f /usr/share/kibana/config/kibana_logs.log