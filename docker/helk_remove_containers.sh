#!/bin/bash

# HELK script: helk_remove_containers.sh
# HELK script description: HELK Removal
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# *********** Check if user is root ***************
if [[ $EUID -ne 0 ]]; then
   echo "[HELK-INSTALLATION-INFO] YOU MUST BE ROOT TO RUN THIS SCRIPT!!!" 
   exit 1
fi

# *********** Set Log File ***************
LOGFILE="/var/log/helk-install.log"
echoerror() {
    printf "${RC} * ERROR${EC}: $@\n" 1>&2;
}

echo "[HELK-REMOVE-CONTAINERS] Stopping all running containers.."
docker stop $(docker ps -a | awk '{ print $1,$2 }' | grep helk | awk '{print $1 }') >> $LOGFILE 2>&1
ERROR=$?
if [ $ERROR -ne 0 ]; then
    echoerror "Could not stop running containers.."
    exit 1
fi

echo "[HELK-REMOVE-CONTAINERS] Removing all containers.."
docker rm $(docker ps -a | awk '{ print $1,$2 }' | grep helk | awk '{print $1 }') >> $LOGFILE 2>&1
ERROR=$?
if [ $ERROR -ne 0 ]; then
    echoerror "Could not remove containers.."
    exit 1
fi

echo "[HELK-REMOVE-CONTAINERS] Removing all images.."
docker rmi $(docker images -a | awk '{ print $1,$3 }' | grep helk | awk '{print $2}') >> $LOGFILE 2>&1
ERROR=$?
if [ $ERROR -ne 0 ]; then
    echoerror "Could not remove images.."
    exit 1
fi

echo "[HELK-REMOVE-CONTAINERS] You have successfully removed HELK containers.."
