#!/bin/sh

set -e

# HELK script: nginx-entrypoint.sh
# HELK script description: Creates certificate for Jupyter Notebook SSL
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# ************* Creating JupyterHub Certificate ***********
openssl req \
    -x509 \
    -nodes \
    -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/ssl/private/HELK_Nginx.key \
    -out /etc/ssl/certs/HELK_Nginx.crt \
    -subj "/C=US/ST=VA/L=VA/O=HELK/OU=HELK Nginx/CN=HELK"

exit 0