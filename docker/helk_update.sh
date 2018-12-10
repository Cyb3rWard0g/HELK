#!/bin/bash

# HELK script: helk_update.sh
# HELK script description: Update and Rebuild HELK
# HELK build Stage: Alpha
# HELK ELK version: 6.3.1
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# Script Author: Dev Dua (@devdua)
# License: GPL-3.0

if [[ $EUID -ne 0 ]]; then
   echo "[HELK-UPDATE-INFO] YOU MUST BE ROOT TO RUN THIS SCRIPT!!!" 
   exit 1
fi

set_helk_license(){    
    # *********** Accepting Defaults or Allowing user to set HELK License ***************
    local license_input
    read -t 30 -p "[HELK-UPDATE-INFO] Set HELK License. Default value is basic: " -e -i "basic" license_input
    license_choice=${license_input:-"basic"}
    # *********** Validating License Input ***************
    case $license_choice in
        basic)
        ;;
        trial)
        ;;
        *)
            echo "[HELK-UPDATE-ERROR] Not a valid license. Valid Options: basic or trial"
            exit 1
        ;;
    esac
}

check_min_requirements(){
    systemKernel="$(uname -s)"
    echo "[HELK-UPDATE-INFO] HELK being hosted on a $systemKernel box"
    if [ "$systemKernel" == "Linux" ]; then 
        AVAILABLE_MEMORY=$(awk '/MemAvailable/{printf "%.f", $2/1024/1024}' /proc/meminfo)
        if [ "${AVAILABLE_MEMORY}" -ge "12" ] ; then
            echo "[HELK-UPDATE-INFO] Available Memory (GB): ${AVAILABLE_MEMORY}"
        else
            echo "[HELK-UPDATE-ERROR] YOU DO NOT HAVE ENOUGH AVAILABLE MEMORY"
            echo "[HELK-UPDATE-ERROR] Available Memory (GB): ${AVAILABLE_MEMORY}"
            echo "[HELK-UPDATE-ERROR] Check the requirements section in our UPDATE Wiki"
            echo "[HELK-UPDATE-ERROR] UPDATE Wiki: https://github.com/Cyb3rWard0g/HELK/wiki/UPDATE"
            exit 1
        fi
    else
        echo "[HELK-UPDATE-INFO] Error retrieving memory info for $systemKernel. Make sure you have at least 12GB of available memory!"
    fi

    # CHECK DOCKER DIRECTORY SPACE
    echo "[HELK-UPDATE-INFO] Making sure you assigned enough disk space to the current Docker base directory"
    AVAILABLE_DOCKER_DISK=$(df -m $(docker info --format '{{.DockerRootDir}}') | awk '$1 ~ /\//{printf "%.f\t\t", $4 / 1024}')    
    if [ "${AVAILABLE_DOCKER_DISK}" -ge "30" ]; then
        echo "[HELK-UPDATE-INFO] Available Docker Disk: $AVAILABLE_DOCKER_DISK"
    else
        echo "[HELK-UPDATE-ERROR] YOU DO NOT HAVE ENOUGH DOCKER DISK SPACE ASSIGNED"
        echo "[HELK-UPDATE-ERROR] Available Docker Disk: $AVAILABLE_DOCKER_DISK"
        echo "[HELK-UPDATE-ERROR] Check the requirements section in our UPDATE Wiki"
        echo "[HELK-UPDATE-ERROR] UPDATE Wiki: https://github.com/Cyb3rWard0g/HELK/wiki/UPDATE"
        exit 1
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
            "[!] Could not install Git (Error Code: $ERROR). Check $LOGFILE for details."
            exit 1
        fi
        echo "Git successfully installed." >> $LOGFILE
    fi

    if [[ -z "$(git remote | grep helk-repo)" ]]; then
        git remote add helk-repo https://github.com/Cyb3rWard0g/HELK.git  >> $LOGFILE 2>&1 
    else
        echo "HELK repo exists" >> $LOGFILE 2>&1
    fi
    
    git remote update >> $LOGFILE 2>&1
    COMMIT_DIFF=$(git rev-list --count master...helk-repo/master)
    CURRENT_COMMIT=$(git rev-parse HEAD)
    REMOTE_LATEST_COMMIT=$(git rev-parse helk-repo/master)
    echo "HEAD commits --> Current: $CURRENT_COMMIT | Remote: $REMOTE_LATEST_COMMIT" >> $LOGFILE 2>&1
    
    if  [ ! "$COMMIT_DIFF" == "0" ]; then
        echo "Possibly new release available. Commit diff --> $COMMIT_DIFF" >> $LOGFILE 2>&1
        IS_MASTER_BEHIND=$(git branch -v | grep master | grep behind)
        
        if [[ -z $IS_MASTER_BEHIND ]]; then
            echo "Current master branch ahead of remote branch. Exiting..." >> $LOGFILE 2>&1
            echo "[HELK-UPDATE-INFO] No updates available."

        elif [ ! "$CURRENT_COMMIT" == "$REMOTE_LATEST_COMMIT" ]; then
            echo "Difference in HEAD commits --> Current: $CURRENT_COMMIT | Remote: $REMOTE_LATEST_COMMIT" >> $LOGFILE 2>&1   
            echo "[HELK-UPDATE-INFO] New release available. Pulling new code."
            git checkout master >> $LOGFILE 2>&1
            git pull helk-repo master >> $LOGFILE 2>&1
            REBUILD_NEEDED=1
            touch /tmp/helk-update
            echo $REBUILD_NEEDED > /tmp/helk-update
        fi
    else
        echo "[HELK-UPDATE-INFO] No updates available."    
    fi
}

update_helk() {
    set_helk_license
    echo -e "[HELK-UPDATE-INFO] Stopping HELK and starting update"
    docker-compose -f docker-compose-helk-elastic-${license_choice}.yml down >> $LOGFILE 2>&1
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echo -e "[!] Could not stop HELK via docker-compose (Error Code: $ERROR). You're possibly running a different HELK license than chosen - $license_choice"
        exit 1
    fi

    check_min_requirements

    echo "[HELK-UPDATE-INFO] Rebuilding HELK via docker-compose"
    docker-compose -f docker-compose-helk-elastic-${license_choice}.yml up --build -d -V --force-recreate --always-recreate-deps >> $LOGFILE 2>&1
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echo -e "[!] Could not run HELK via docker-compose (Error Code: $ERROR). Check $LOGFILE for details."
        exit 1
    fi
    
    secs=$((3 * 60))
    while [ $secs -gt 0 ]; do
        echo -ne "\033[0K\r[HELK-UPDATE-INFO] Rebuild succeeded, waiting $secs seconds for services to start..."
        sleep 1
        : $((secs--))
    done
    echo -e "\n[HELK-UPDATE-INFO] YOUR HELK HAS BEEN UPDATED!"
    echo 0 > /tmp/helk-update
    exit 1
}

LOGFILE="/var/log/helk-update.log"
REBUILD_NEEDED=0

if [[ -e /tmp/helk-update ]]; then
    UPDATES_FETCHED=`cat /tmp/helk-update`

    if [ "$UPDATES_FETCHED" == "1" ]; then
      echo -e "[HELK-UPDATE-INFO] Updates already downloaded. Starting update..."    
      update_helk
    fi
fi

echo "[HELK-UPDATE-INFO] Checking GitHub for updates..."   
check_github

if [ $REBUILD_NEEDED == 1 ]; then
    update_helk
else
    echo -e "[HELK-UPDATE-INFO] YOUR HELK IS ALREADY UP-TO-DATE."
    exit 1
fi