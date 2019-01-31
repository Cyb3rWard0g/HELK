#!/bin/bash

# HELK script: helk_update.sh
# HELK script description: Update and Rebuild HELK
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# Script Author: Dev Dua (@devdua)
# License: GPL-3.0

RED='\033[0;31m'
CYAN='\033[0;36m'
WAR='\033[1;33m'
STD='\033[0m'

if [[ $EUID -ne 0 ]]; then
   echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} YOU MUST BE ROOT TO RUN THIS SCRIPT!!!" 
   exit 1
fi

# *********** Asking user for Basic or Trial subscription of ELK ***************
set_helk_subscription(){
    if [[ -z "$SUBSCRIPTION_CHOICE" ]]; then
        # *********** Accepting Defaults or Allowing user to set HELK subscription ***************
        while true; do
            local subscription_input
            read -t 30 -p ">> Set HELK elastic subscription (basic or trial): " -e -i "basic" subscription_input
            READ_INPUT=$?
            SUBSCRIPTION_CHOICE=${subscription_input:-"basic"}
            if [ $READ_INPUT = 142 ]; then
                echo -e "\n${CYAN}[HELK-UPDATE-INFO]${STD} HELK elastic subscription set to ${SUBSCRIPTION_CHOICE}"
                break
            else
                echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} HELK elastic subscription set to ${SUBSCRIPTION_CHOICE}"
                # *********** Validating subscription Input ***************
                case $SUBSCRIPTION_CHOICE in
                    basic) break;;
                    trial) break;;
                    *)
                        echo -e "${RED}[HELK-UPDATE-ERROR]${STD} Not a valid subscription. Valid Options: basic or trial"
                    ;;
                esac
            fi
        done
    fi
}

# *********** Asking user for docker compose config ***************
set_helk_build(){
    if [[ -z "$HELK_BUILD" ]]; then
        while true; do
            echo " "
            echo "*****************************************************"	
            echo "*      HELK - Docker Compose Build Choices          *"
            echo "*****************************************************"
            echo " "
            echo "1. KAFKA + KSQL + ELK + NGNIX + ELASTALERT                   "
            echo "2. KAFKA + KSQL + ELK + NGNIX + ELASTALERT + SPARK + JUPYTER "
            echo " "

            local CONFIG_CHOICE
            read -t 30 -p ">> Enter build choice [ 1 - 2]: " -e -i "1" CONFIG_CHOICE
            READ_INPUT=$?
            HELK_BUILD=${CONFIG_CHOICE:-"helk-kibana-analysis"}
            if [ $READ_INPUT = 142 ]; then
                echo -e "\n${CYAN}[HELK-UPDATE-INFO]${STD} HELK build set to ${HELK_BUILD}"
                break
            else
                echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} HELK build set to ${HELK_BUILD}"
                case $CONFIG_CHOICE in
                    1) HELK_BUILD='helk-kibana-analysis';break ;;
                    2) HELK_BUILD='helk-kibana-notebook-analysis';break;;
                    *) 
                        echo -e "\n${RED}[HELK-UPDATE-ERROR]${STD} Not a valid build"
                    ;;
                esac
            fi
        done
    fi
}

check_min_requirements(){
    systemKernel="$(uname -s)"
    echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} HELK being hosted on a $systemKernel box"
    if [ "$systemKernel" == "Linux" ]; then 
        AVAILABLE_MEMORY=$(awk '/MemAvailable/{printf "%.f", $2/1024/1024}' /proc/meminfo)
        if [ "${AVAILABLE_MEMORY}" -ge "11" ] ; then
            echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} Available Memory (GB): ${AVAILABLE_MEMORY}"
        else
            echo -e "${RED}[HELK-UPDATE-ERROR]${STD} YOU DO NOT HAVE ENOUGH AVAILABLE MEMORY"
            echo -e "${RED}[HELK-UPDATE-ERROR]${STD} Available Memory (GB): ${AVAILABLE_MEMORY}"
            echo -e "${RED}[HELK-UPDATE-ERROR]${STD} Check the requirements section in our UPDATE Wiki"
            echo -e "${RED}[HELK-UPDATE-ERROR]${STD} UPDATE Wiki: https://github.com/Cyb3rWard0g/HELK/wiki/UPDATE"
            exit 1
        fi
    else
        echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} Error retrieving memory info for $systemKernel. Make sure you have at least 11GB of available memory!"
    fi

    # CHECK DOCKER DIRECTORY SPACE
    echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} Making sure you assigned enough disk space to the current Docker base directory"
    AVAILABLE_DOCKER_DISK=$(df -m $(docker info --format '{{.DockerRootDir}}') | awk '$1 ~ /\//{printf "%.f\t\t", $4 / 1024}')    
    if [ "${AVAILABLE_DOCKER_DISK}" -ge "25" ]; then
        echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} Available Docker Disk: $AVAILABLE_DOCKER_DISK"
    else
        echo -e "${RED}[HELK-UPDATE-ERROR]${STD} YOU DO NOT HAVE ENOUGH DOCKER DISK SPACE ASSIGNED"
        echo -e "${RED}[HELK-UPDATE-ERROR]${STD} Available Docker Disk: $AVAILABLE_DOCKER_DISK"
        echo -e "${RED}[HELK-UPDATE-ERROR]${STD} Check the requirements section in our UPDATE Wiki"
        echo -e "${RED}[HELK-UPDATE-ERROR]${STD} UPDATE Wiki: https://github.com/Cyb3rWard0g/HELK/wiki/UPDATE"
        exit 1
    fi
}

check_git_status(){
    GIT_STATUS=$(git status 2>&1)
    RETURN_CODE=$?
    echo -e "Git status: $GIT_STATUS_FATAL, RetVal : $RETURN_CODE" >> $LOGFILE
    if [[ -z $GIT_STATUS_FATAL && $RETURN_CODE -gt 0 ]]; then 
        echo -e "${WAR}[HELK-UPDATE-WARNING]${STD} Git repository corrupted."
        read -p ">> To fix this, all your local modifications to HELK will be overwritten. Do you wish to continue? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            GIT_REPO_CLEAN=0
            echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} HELK will now be refreshed. Re-initializing .git..."
            cd ..
            git init >> $LOGFILE
            cd docker
            echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} Git repository fixed. Fetching latest version of HELK..."
        else
            exit
        fi
    else
        echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} Sanity check passed."   
    fi
}

check_github(){

    if [ -x "$(command -v git)" ]; then
        echo -e "Git is available" >> $LOGFILE
    else
        echo "Git is not available" >> $LOGFILE
        apt-get -qq update >> $LOGFILE 2>&1 && apt-get -qqy install git-core >> $LOGFILE 2>&1
        ERROR=$?
        if [ $ERROR -ne 0 ]; then
            echo -e "${RED}[!]${STD} Could not install Git (Error Code: $ERROR). Check $LOGFILE for details."
            exit 1
        fi
        echo "Git successfully installed." >> $LOGFILE
    fi

    echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} Sanity check..."   
    check_git_status

    if [ $GIT_REPO_CLEAN == 1 ]; then
        if [[ -z "$(git remote | grep helk-repo)" ]]; then
            git remote add helk-repo https://github.com/Cyb3rWard0g/HELK.git  >> $LOGFILE 2>&1 
        else
            echo "HELK repo exists" >> $LOGFILE 2>&1
        fi
        
        git remote update >> $LOGFILE 2>&1
        COMMIT_DIFF=$(git rev-list --count master...helk-repo/master 2>&1)
        CURRENT_COMMIT=$(git rev-parse HEAD 2>&1)
        REMOTE_LATEST_COMMIT=$(git rev-parse helk-repo/master 2>&1)
        echo "HEAD commits --> Current: $CURRENT_COMMIT | Remote: $REMOTE_LATEST_COMMIT" >> $LOGFILE 2>&1
        
        if  [ ! "$COMMIT_DIFF" == "0" ]; then
            echo "Possibly new release available. Commit diff --> $COMMIT_DIFF" >> $LOGFILE 2>&1
            IS_MASTER_BEHIND=$(git branch -v | grep master | grep behind)

            # IF HELK HAS BEEN CLONED FROM OFFICIAL REPO
            if [ ! "$CURRENT_COMMIT" == "$REMOTE_LATEST_COMMIT" ]; then
                echo "Difference in HEAD commits --> Current: $CURRENT_COMMIT | Remote: $REMOTE_LATEST_COMMIT" >> $LOGFILE 2>&1   
                echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} New release available. Pulling new code."
                git checkout master >> $LOGFILE 2>&1
                git clean  -d  -fx . >> $LOGFILE 2>&1
                git pull helk-repo master >> $LOGFILE 2>&1
                REBUILD_NEEDED=1
                touch /tmp/helk-update
                echo $REBUILD_NEEDED > /tmp/helk-update

            # IF HELK HAS BEEN CLONED FROM THE OFFICIAL REPO & MODIFIED
            elif [[ -z $IS_MASTER_BEHIND ]]; then
                echo "Current master branch ahead of remote branch, possibly modified. Exiting..." >> $LOGFILE 2>&1
                echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} No updates available."

            else
                echo "Repository misconfigured. Exiting..." >> $LOGFILE 2>&1
                echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} No updates available."

            fi
        else
            echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} No updates available."    
        fi
    else
        cd ..
        git clean  -d  -fx . >> $LOGFILE 2>&1
        git remote add helk-repo https://github.com/Cyb3rWard0g/HELK.git  >> $LOGFILE 2>&1
        git pull helk-repo master >> $LOGFILE 2>&1    
    fi
}

update_helk() {
    
    set_helk_build
    set_helk_subscription

    echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} Stopping HELK and starting update"
    COMPOSE_CONFIG="${HELK_BUILD}-${SUBSCRIPTION_CHOICE}.yml"
    ## ****** Setting KAFKA ADVERTISED_LISTENER environment variable ***********
    export ADVERTISED_LISTENER=$HOST_IP

    echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} Building & running HELK from $COMPOSE_CONFIG file.."
    docker-compose -f $COMPOSE_CONFIG down >> $LOGFILE 2>&1
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echo -e "${RED}[!]${STD} Could not stop HELK via docker-compose (Error Code: $ERROR). You're possibly running a different HELK license than chosen - $license_choice"
        exit 1
    fi

    check_min_requirements

    echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} Rebuilding HELK via docker-compose"
    docker-compose -f $COMPOSE_CONFIG up --build -d -V --force-recreate --always-recreate-deps >> $LOGFILE 2>&1
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echo -e "${RED}[!]${STD} Could not run HELK via docker-compose (Error Code: $ERROR). Check $LOGFILE for details."
        exit 1
    fi
    
    secs=$((3 * 60))
    while [ $secs -gt 0 ]; do
        echo -ne "\033[0K\r${CYAN}[HELK-UPDATE-INFO]${STD} Rebuild succeeded, waiting $secs seconds for services to start..."
        sleep 1
        : $((secs--))
    done
    echo -e "\n${CYAN}[HELK-UPDATE-INFO]${STD} YOUR HELK HAS BEEN UPDATED!"
    echo 0 > /tmp/helk-update
    exit 1
}

LOGFILE="/var/log/helk-update.log"
REBUILD_NEEDED=0
GIT_REPO_CLEAN=1

if [[ -e /tmp/helk-update ]]; then
    UPDATES_FETCHED=`cat /tmp/helk-update`

    if [ "$UPDATES_FETCHED" == "1" ]; then
      echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} Updates already downloaded. Starting update..."    
      update_helk
    fi
fi

echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} Checking GitHub for updates..."   
check_github

if [ $REBUILD_NEEDED == 1 ]; then
    update_helk
elif [ $GIT_REPO_CLEAN == 0 ]; then
    echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} HELK repository refreshed, please terminate this shell & run the update script again."
    exit 1
else
    echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} YOUR HELK IS ALREADY UP-TO-DATE."
    exit 1
fi