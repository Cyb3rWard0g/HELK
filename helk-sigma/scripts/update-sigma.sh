#!/bin/bash

# HELK script: update-sigma.sh
# HELK script description: Pull current Sigma repository, compile rules to queries and import them to Kibana
# HELK build Stage: Alpha
# Author: Thomas Patzke (thomas@patzke.org)
# License: GPL-3.0

# *********** Setting Variables ***************
SIGMA_DIR=/opt/sigma/sigma

cd $SIGMA_DIR
git pull
tools/sigmac -t kibana -c tools/config/helk.yml -Ooutput=curl -Oes=helk-elasticsearch:9200 -o import-sigma-to-kibana.sh -r rules/windows
. import-sigma-to-kibana.sh
