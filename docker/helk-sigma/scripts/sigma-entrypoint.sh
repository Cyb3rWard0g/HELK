#!/bin/bash

# HELK script: sigma-entrypoint.sh
# HELK script description: Waits for Kibana to getting available and starts initial Sigma update
# HELK build Stage: Alpha
# Author: Thomas Patzke
# License: GPL-3.0

# References: 
# https://github.com/Neo23x0/sigma

# *********** Setting Variables ***************
KIBANA="http://helk-kibana:5601"

# *********** Waiting for Kibana to be available ***************
until curl -s $KIBANA -o /dev/null; do
    sleep 1
done

# *********** Waiting for Kibana Dashboards to be available ***************
# This ensures that the index mappings required for import of the Kibana rules are available
until curl -s $KIBANA/api/saved_objects/?type=dashboard | jq -e '.total > 0'; do
    sleep 1
done

# *********** Loading Sigma searches ***************
/opt/sigma/scripts/update-sigma.sh
