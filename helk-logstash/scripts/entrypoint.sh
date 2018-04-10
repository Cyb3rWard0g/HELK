#!/bin/sh

# HELK script: entrypoint.sh
# HELK script description: Restarts and runs Logstash service
# HELK build version: 0.9 (Alpha)
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

# Start graceful termination of Logstash services that might be running before running the entrypoint script.
_term() {
  echo "Terminating HELK Services"
  service logstash stop
  exit 0
}
trap _term SIGTERM

# Removing PID files just in case the graceful termination fails
rm -f /var/run/logstash.pid

# *********** Setting Logstash Heap Size***************
# https://www.elastic.co/guide/en/logstash/current/performance-troubleshooting.html
sed -i "s/#*-Xmx[0-9]\+g/-Xmx2g/g" /etc/logstash/jvm.options
sed -i "s/#*-Xms[0-9]\+g/-Xms2g/g" /etc/logstash/jvm.options

# *********** Start HELK services ***************
echo "[HELK-DOCKER-INSTALLATION-INFO] Waiting for elasticsearch URI to be accessible.."
until curl -s helk-elasticsearch:9200 -o /dev/null; do
    sleep 1
done

echo "[HELK-DOCKER-INSTALLATION-INFO] Starting Logstash services.."
service logstash start

echo "[HELK-DOCKER-INSTALLATION-INFO] Pushing Logstash Logs to console.."
tail -f /var/log/logstash/*-plain.log