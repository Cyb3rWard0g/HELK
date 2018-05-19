#!/bin/bash

# HELK script: update-sigma.sh
# HELK script description: Pull current Sigma repository, compile rules to queries and import them to Kibana
# HELK build version: 0.9 (Alpha)
# Author: Thomas Patzke (thomas@patzke.org)
# License: BSD 3-Clause

# *********** Setting Variables ***************
SIGMA_DIR=/opt/helk/sigma

cd $SIGMA_DIR
git pull
tools/sigmac -t kibana -c tools/config/helk.yml -Ooutput=curl -o import-sigma-to-kibana.sh -r rules/windows
. import-sigma-to-kibana.sh
