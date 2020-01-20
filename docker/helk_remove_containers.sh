#!/bin/bash

# HELK script: helk_remove_containers.sh
# HELK script description: HELK Removal
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

LABEL="[HELK-REMOVE-CONTAINERS]"

# *********** Check if user is root ***************
if [[ $EUID -ne 0 ]]; then
   echo "[HELK-INSTALLATION-INFO] YOU MUST BE ROOT TO RUN THIS SCRIPT!!!"
   exit 1
fi

# *********** Set Log File ***************
LOGFILE="/var/log/helk-install.log"
echoerror() {
    printf "${RC} * ERROR${EC}: $@\n" 1>&2;
    echo -e "\nPlease see more information in the log file: $LOGFILE\n"
}

# *********** Get installation compose-file ***********
while true; do
    read -e -p "$LABEL What config did you use for installation? " -i "helk-kibana-analysis-basic.yml" INSTALL_FILE
    case "$INSTALL_FILE" in
        helk-kibana-analysis-basic.yml|helk-kibana-analysis-trial.yml)
            break;;
        helk-kibana-analysis-alert-basic.yml|helk-kibana-analysis-alert-trial.yml)
            break;;
        helk-kibana-notebook-analysis-basic.yml|helk-kibana-notebook-analysis-trial.yml)
            break;;
        helk-kibana-notebook-analysis-alert-basic.yml|helk-kibana-notebook-analysis-alert-trial.yml)
            break;;
        *)
            echo "The config file you entered does not exist..."
            echo "Please provide a valid config file."
    esac
done


# *********** Prune volumes ***************
while true; do
    read -e -p "$LABEL Do you want to prune the es_data volume ? " -i "yes" PRUNE
    case "$PRUNE" in
        yes)
            docker volume prune
            break;;			
        no)
            break;;
        *)
            echo "$LABEL Error, you can only chose yes or no..."
    esac
done

# *********** Stop, remove containers, volumes and network ***********
echo "$LABEL Using docker-compose to remove installation..."
if [ "$(command -v docker-compose; echo $?)" != 0 ]; then
    /usr/local/bin/docker-compose -f $INSTALL_FILE down --rmi all -v >> $LOGFILE 2>&1 # try to force command
else
    docker-compose -f $INSTALL_FILE down --rmi all -v >> $LOGFILE 2>&1
fi
if [ $? -ne 0 ]; then
    echoerror "Error while trying docker-compose command.."
    exit 1
fi

echo "$LABEL Removing all images..."
docker rmi $(docker images -a | awk '{ print $1,$3 }' | grep 'cyb3rward0g\|helk\|logstash\|kibana\|elasticsearch\|cp-ksql' | awk '{ print $2 }') >> $LOGFILE 2>&1
ERROR=$?
if [ $ERROR -ne 0 ]; then
    echoerror "Could not remove images.."
    exit 1
fi

# *********** Remove HELK service from firewalld ***********
echo "$LABEL Removing firewall service..."
rm /etc/firewalld/services/helk.xml >> $LOGFILE 2>&1
if [ $? -ne 0 ]; then
    echoerror "Could not remove file from firewalld directory..."
    exit 1
fi

echo "$LABEL Reloading firewall..."
firewall-cmd --reload >> $LOGFILE 2>&1
if [ $? -ne 0 ]; then
    echoerror "Could not reload firewall..."
    exit 1
fi

echo "$LABEL You have successfully removed HELK containers.."
