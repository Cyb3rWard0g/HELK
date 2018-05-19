#!/bin/bash

# HELK script: sigma-entrypoint.sh
# HELK script description: Waits for Kibana to getting available and starts initial Sigma update
# HELK build version: 0.9 (Alpha)
# Author: Thomas Patzke
# License: BSD 3-Clause

# References: 
# https://github.com/Neo23x0/sigma

# *********** Setting Variables ***************
KIBANA="http://helk-kibana:5601"

# *********** Waiting for Kibana to be available ***************
until curl -s $KIBANA -o /dev/null; do
    sleep 1
done

# *********** Loading Sigma searches ***************
/opt/helk/scripts/update-sigma.sh
