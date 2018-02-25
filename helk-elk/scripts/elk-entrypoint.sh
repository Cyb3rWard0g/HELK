#!/bin/sh

# HELK script: elk-entrypoint.sh
# HELK script description: Restarts and runs ELK services
# HELK build version: 0.9 (Alpha)
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

# Start graceful termination of HELK services that might be running before running the entrypoint script.
_term() {
  echo "Terminating HELK Services"
  service elasticsearch stop
  service logstash stop
  service kibana stop
  service cerebro stop
  exit 0
}
trap _term SIGTERM

# Removing PID files just in case the graceful termination fails
rm -f /var/run/elasticsearch/elasticsearch.pid \
    /var/run/logstash.pid \
    /var/run/kibana.pid \
    /var/run/cerebro.pid

# *********** Setting ES Heap Size***************
# https://serverfault.com/questions/881383/automatically-set-java-heap-size-for-elasticsearch-on-linux
memoryInKb="$(awk '/MemTotal/ {print $2}' /proc/meminfo)"
heapSize="$(expr $memoryInKb / 1024 / 1000 / 2)"
sed -i "s/#*-Xmx[0-9]\+g/-Xmx${heapSize}g/g" /etc/elasticsearch/jvm.options
sed -i "s/#*-Xms[0-9]\+g/-Xms${heapSize}g/g" /etc/elasticsearch/jvm.options

# *********** Setting Logstash Heap Size***************
# https://www.elastic.co/guide/en/logstash/current/performance-troubleshooting.html
sed -i "s/#*-Xmx[0-9]\+g/-Xmx2g/g" /etc/logstash/jvm.options
sed -i "s/#*-Xms[0-9]\+g/-Xms2g/g" /etc/logstash/jvm.options

# *********** Start HELK services ***************
echo "[HELK-DOCKER-INSTALLATION-INFO] Starting elasticsearch service"
service elasticsearch start
echo "[HELK-DOCKER-INSTALLATION-INFO] Waiting for elasticsearch URI to be accessible.."
until curl -s localhost:9200 -o /dev/null; do
    sleep 1
done

echo "[HELK-DOCKER-INSTALLATION-INFO] Starting remaining services.."
service kibana start
service nginx restart
service logstash start
service cerebro start
service cron start

    # *********** Creating Kibana Dashboards, visualizations and index-patterns ***************
echo "[HELK-DOCKER-INSTALLATION-INFO] Running helk_kibana_setup.sh script..."
./elk-kibana-setup.sh

echo "[HELK-DOCKER-INSTALLATION-INFO] Pushing logstash Logs to console.."
tail -f /var/log/logstash/*-plain.log