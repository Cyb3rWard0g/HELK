#!/bin/bash

# HELK script: helk_geoipdb_update.sh
# HELK script description: Update the MaxMind GeoIP databases
# HELK build version: 0.9 (BETA)
# HELK ELK version: 6.x
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

# References: 

# HELK Supporting script
# SOF-ELK Supporting script (C)2016 Lewes Technology Consulting, LLC
# https://github.com/philhagen/sof-elk/blob/develop/supporting-scripts/geoip_update.sh

GEOIP_LIBDIR=/etc/logstash/geoip
GEOIP_CITYSOURCEURL=http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz
GEOIP_CITYSOURCEFILE=GeoLite2-City.mmdb.gz

RUNNOW=0

# parse any command line arguments
if [ $# -gt 0 ]; then
    while true; do
        if [ $1 ]; then
            if [ $1 == '-now' ]; then
                RUNNOW=1
            fi
            shift
        else
            break
        fi
    done
fi

if [ ! -d ${GEOIP_LIBDIR} ]; then
    mkdir -p ${GEOIP_LIBDIR}
fi

if [ $RUNNOW -eq 0 ]; then
    # wait up to 20min to start, so all these VMs don't hit the server at the same exact time
    randomNumber=$RANDOM
    let "randomNumber %= 1800"
    sleep ${randomNumber}
fi

cd ${GEOIP_LIBDIR}
wget -N -q ${GEOIP_CITYSOURCEURL}
gunzip -f ${GEOIP_CITYSOURCEFILE}
