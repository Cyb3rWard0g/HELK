#!/bin/sh

# HELK script: nginx-entrypoint.sh
# HELK script description: Restarts and runs Nginx service
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

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

# ************* Creating JupyterHub Certificate ***********
openssl req \
    -x509 \
    -nodes \
    -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/ssl/private/HELK_Nginx.key \
    -out /etc/ssl/certs/HELK_Nginx.crt \
    -subj "/C=US/ST=VA/L=VA/O=HELK/OU=HELK Nginx/CN=HELK"

echo "[HELK-DOCKER-INSTALLATION-INFO] Starting remaining services.."
service nginx restart

echo "[HELK-DOCKER-INSTALLATION-INFO] Pushing Nginx Logs to console.."
tail -f /var/log/nginx/*.log