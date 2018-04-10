#!/bin/sh

# HELK script: entrypoint.sh
# HELK script description: Restarts and runs elasticsearch service
# HELK build version: 0.9 (Alpha)
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

# Start graceful termination of elasticsearch service that might be running before running the entrypoint script.
_term() {
  echo "Terminating elasticsearch service"
  service elasticsearch stop
  service cerebro stop
  exit 0
}
trap _term SIGTERM

# Removing PID files just in case the graceful termination fails
rm -f /var/run/elasticsearch/elasticsearch.pid

# *********** Setting ES Heap Size***************
# https://serverfault.com/questions/881383/automatically-set-java-heap-size-for-elasticsearch-on-linux
memoryInKb="$(awk '/MemTotal/ {print $2}' /proc/meminfo)"
heapSize="$(expr $memoryInKb / 1024 / 1000 / 2)"
sed -i "s/#*-Xmx[0-9]\+g/-Xmx${heapSize}g/g" /etc/elasticsearch/jvm.options
sed -i "s/#*-Xms[0-9]\+g/-Xms${heapSize}g/g" /etc/elasticsearch/jvm.options

# *********** Start elasticsearch services ***************
echo "[HELK-DOCKER-INSTALLATION-INFO] Starting Elasticsearch service"
service elasticsearch start

echo "[HELK-DOCKER-INSTALLATION-INFO] Waiting for elasticsearch URI to be accessible.."
until curl -s localhost:9200 -o /dev/null; do
    sleep 1
done

echo "[HELK-DOCKER-INSTALLATION-INFO] Starting Cerebro service"
service cerebro start

echo "[HELK-DOCKER-INSTALLATION-INFO] Pushing Elasticsearch Logs to console.."
tail -f /var/log/elasticsearch/*.log