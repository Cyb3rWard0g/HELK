#!/bin/sh

# HELK script: entrypoint.sh
# HELK script description: Restarts and runs Nginx service
# HELK build version: 0.9 (Alpha)
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

# Start graceful termination of HELK services that might be running before running the entrypoint script.
_term() {
  echo "Terminating Nginx Services"
  service nginx stop
  exit 0
}
trap _term SIGTERM

until curl -s helk-elasticsearch:9200 -o /dev/null; do
    sleep 1
done

echo "[HELK-DOCKER-INSTALLATION-INFO] Starting remaining services.."
service nginx restart

echo "[HELK-DOCKER-INSTALLATION-INFO] Pushing Nginx Logs to console.."
tail -f /var/log/nginx/*.log