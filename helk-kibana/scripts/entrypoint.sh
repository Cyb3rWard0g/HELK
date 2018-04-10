#!/bin/sh

# HELK script: entrypoint.sh
# HELK script description: Restarts and runs Kibana service
# HELK build version: 0.9 (Alpha)
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

# Start graceful termination of kibana services that might be running before running the entrypoint script.
_term() {
  echo "Terminating Kibana Service"
  service kibana stop
  exit 0
}
trap _term SIGTERM

# Removing PID files just in case the graceful termination fails
rm -f /var/run/kibana.pid

# *********** Start Kibana services ***************
echo "[HELK-DOCKER-INSTALLATION-INFO] Waiting for elasticsearch URI to be accessible.."
until curl -s helk-elasticsearch:9200 -o /dev/null; do
    sleep 1
done

echo "[HELK-DOCKER-INSTALLATION-INFO] Starting Kibana service.."
service kibana start

    # *********** Creating Kibana Dashboards, visualizations and index-patterns ***************
echo "[HELK-DOCKER-INSTALLATION-INFO] Running helk_kibana_setup.sh script..."
./elk-kibana-setup.sh

echo "[HELK-DOCKER-INSTALLATION-INFO] Pushing Kibana logs to console.."
tail -f /var/log/kibana/kibana.log