#!/bin/sh

# HELK script: analytics-entryppoint.sh
# HELK script description: Restart HELK Analytic services
# HELK build version: 0.9 (Alpha)
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

# Start graceful termination of HELK services that might be running before running the entrypoint script.
_term() {
  echo "Terminating HELK analytics services"
  service analytics stop
  exit 0
}
trap _term SIGTERM

# Removing PID files just in case the graceful termination fails
rm -f /var/run/analytics.pid

echo "[HELK-DOCKER-INSTALLATION-INFO] Starting analytic services.."
service analytics start
sleep 5
echo "[HELK-DOCKER-INSTALLATION-INFO] Pushing analytic Logs to console.."
tail -f /var/log/analytics/analytics.log