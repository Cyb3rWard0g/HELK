#!/bin/bash

# HELK script: helk_remove_containers.sh
# HELK script description: HELK Removal
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0
HELK_INFO_TAG="[HELK-REMOVE-CONTAINERS-INFO]"
HELK_ERROR_TAG="[HELK-REMOVE-CONTAINERS-ERROR]"
RED='\033[0;31m'
CYAN='\033[0;36m'
WAR='\033[1;33m'
STD='\033[0m'

# *********** Check if user is root ***************
if [[ $EUID -ne 0 ]]; then
   echo "[HELK-INSTALLATION-INFO] YOU MUST BE ROOT TO RUN THIS SCRIPT!!!"
   exit 1
fi

# *********** Set Log File ***************
LOGFILE="/var/log/helk-install.log"
echoerror() {
    printf "${RED}${RC} * ERROR${EC}: $@\n" 1>&2;
    echo -e "\n${RED}${HELK_ERROR_TAG}${STD} Please see more information in the log file: $LOGFILE\n"
}

# HELK Directory
HELK_DIR="/usr/share/helk"
# HELK Configuration File
HELK_CONF_FILE="$HELK_DIR/helk.conf"
# HELK Information File for operating system
HELK_INFO_FILE="$HELK_DIR/helk_install.info"

get_persist_conf() {
  if [ ! -d "$HELK_DIR" ]; then
    return
  fi
  if [[ -f $HELK_CONF_FILE ]]; then
    COMPOSE_CONFIG=$(cat $HELK_CONF_FILE | grep COMPOSE_CONFIG | cut -d'=' -f2)
  else
    return
  fi
}

# *********** Get installation compose-file ***********
echo -e "${CYAN}${HELK_INFO_TAG}${STD} The following were the HELK install choices and their corresponding docker compose files:"
echo " "
echo -e "${CYAN}1.${STD}KAFKA + KSQL + ELK + NGNIX:"
echo "'helk-kibana-analysis-basic.yml'"
echo " "
echo -e "${CYAN}2.${STD}KAFKA + KSQL + ELK + NGNIX + ELASTALERT:"
echo "'helk-kibana-analysis-alert-basic.yml'"
echo " "
echo -e "${CYAN}3.${STD}KAFKA + KSQL + ELK + NGNIX + SPARK + JUPYTER:"
echo "'helk-kibana-notebook-analysis-basic.yml'"
echo " "
echo -e "${CYAN}4.${STD}KAFKA + KSQL + ELK + NGNIX + SPARK + JUPYTER + ELASTALERT:"
echo "'helk-kibana-notebook-analysis-alert-basic.yml'"
echo " "
get_persist_conf
while true; do
    if [ -z "$COMPOSE_CONFIG" ]; then
      read -e -p "What installation config did you use from the examples above?: " -i "helk-kibana-analysis-basic.yml" INSTALL_FILE
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
    else
      echo -e "${CYAN}${HELK_INFO_TAG}${STD} Detected a previous HELK install using '${COMPOSE_CONFIG}'"
      read -e -p "Use this config (recommended) or supply a different option from the examples above: " -i "${COMPOSE_CONFIG}" INSTALL_FILE
      case "$INSTALL_FILE" in
          helk-kibana-analysis-basic.yml|helk-kibana-analysis-trial.yml)
              break;;
          helk-kibana-analysis-alert-basic.yml|helk-kibana-analysis-alert-trial.yml)
              break;;
          helk-kibana-notebook-analysis-basic.yml|helk-kibana-notebook-analysis-trial.yml)
              break;;
          helk-kibana-notebook-analysis-alert-basic.yml|helk-kibana-notebook-analysis-alert-trial.yml)
              break;;
          "$COMPOSE_CONFIG")
              break;;
          *)
              echo "The config file you entered does not exist..."
              echo "Please provide a valid config file."
      esac
    fi
done

# *********** Stop, remove containers, volumes and network ***********
echo -e "${CYAN}${HELK_INFO_TAG}${STD} Using docker-compose to remove installation..."
if [ "$(command -v docker-compose; echo $?)" != 0 ]; then
    /usr/local/bin/docker-compose -f "$INSTALL_FILE" down --rmi all -v >> $LOGFILE 2>&1 # try to force command
else
    docker-compose -f "$INSTALL_FILE" down --rmi all -v >> $LOGFILE 2>&1
fi
if [ $? -ne 0 ]; then
    echoerror "Error while trying docker-compose command.."
    exit 1
fi

echo -e "${CYAN}${HELK_INFO_TAG}${STD} Removing all images..."
# HELK Images
#docker rmi "$(docker images -a | awk '{ print $1,$3 }' | grep 'otrf\|cyb3rward0g\|helk' | awk '{ print $2 }')" >> $LOGFILE 2>&1
if [ "$(docker images -a | grep 'otrf\|cyb3rward0g\|helk\|logstash\|kibana\|elasticsearch\|cp-ksql' > /dev/null; echo $?)" == 0 ]; then
    docker rmi "$(docker images -a | awk '{ print $1,$3 }' | grep 'otrf\|cyb3rward0g\|helk\|logstash\|kibana\|elasticsearch\|cp-ksql' | awk '{ print $2 }')" >> $LOGFILE 2>&1
fi
#TODO: these get removed in docker compose remove, but at some point may be good to implement this.. either: 1) create custom HELK ELK and KSQL images and this won't be an issue/thing or.. 2) figure out how to give option even though using compose.. However, this is really low hanging fruit, not worried about it for now 2019-01-25
# ELastic/Confluent Images, so give user option to remove them...as the user may be using those for other things on their system
#echo -e "${CYAN}${HELK_INFO_TAG}${STD} You may be using the official, upstream, Elastic (ELK) and Confluent(KSQL) docker images for other components on your machine..."
#while true; do
#    read -e -p "$HELK_INFO_TAG Do you want to delete the docker images for Elasitc (ELK) and Confluent(KSQL) ? " -i "yes" PRUNE
#    case "$PRUNE" in
#        yes)
#            docker rmi "$(docker images -a | awk '{ print $1,$3 }' | grep 'logstash\|kibana\|elasticsearch\|cp-ksql' | awk '{ print $2 }')" >> $LOGFILE 2>&1
#            break;;
#        no)
#            break;;
#        *)
#            echo "$HELK_INFO_TAG Error, you can only chose yes or no..."
#    esac
#done
ERROR=$?
if [ $ERROR -ne 0 ]; then
    echoerror "Could not remove images.."
    exit 1
fi

#TODO: eventually give option, compose file currently removes it
# *********** Prune volumes ***************
#while true; do
#    read -e -p "$HELK_INFO_TAG Do you want to delete all of HELK's Elasticsearch (log) data ? " -i "yes" PRUNE
#    case "$PRUNE" in
#        yes)
#            docker volume rm docker_es_data
#            break;;
#        no)
#            break;;
#        *)
#            echo "$HELK_INFO_TAG Error, you can only chose yes or no..."
#    esac
#done

# *********** Remove HELK service from firewalld ***********
DIST="$(. /etc/os-release && echo "$ID")"

if [[ "$DIST" == "centos" ]]; then
    echo -e "${CYAN}${HELK_INFO_TAG}${STD} Removing firewall service..."
    rm /etc/firewalld/services/helk.xml >> $LOGFILE 2>&1
    if [ $? -ne 0 ]; then
        echoerror "Could not remove file from firewalld directory..."
        exit 1
    fi

    echo -e "${CYAN}${HELK_INFO_TAG}${STD} Reloading firewall..."
    firewall-cmd --reload >> $LOGFILE 2>&1
    if [ $? -ne 0 ]; then
        echoerror "Could not reload firewall..."
        exit 1
    fi
fi

echo -e "${CYAN}${HELK_INFO_TAG}${STD} You have successfully removed HELK containers.."
