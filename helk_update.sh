#!/bin/bash

# HELK script: helk_update.sh
# HELK script description: Update and Rebuild HELK
# HELK build version: v0.1.1-alpha07062018
# HELK ELK version: 6.3.1
# Script Author: Dev Dua (@devdua)
# License: BSD 3-Clause

if [[ $EUID -ne 0 ]]; then
   echo "[HELK-UPDATE-INFO] YOU MUST BE ROOT TO RUN THIS SCRIPT!!!" 
   exit 1
fi

check_min_requirements(){
    systemKernel="$(uname -s)"
    echo "[HELK-UPDATE-INFO] HELK being hosted on a $systemKernel box"
    if [ "$systemKernel" == "Linux" ]; then 
        AVAILABLE_MEMORY=$(awk '/MemAvailable/{printf "%.f", $2/1024/1024}' /proc/meminfo)
        
        # Only checking Available Memory requirements and not Disk, as old images are deleted and replaced with updated ones.
        if [ "${AVAILABLE_MEMORY}" -ge "12" ] ; then
            echo "[HELK-UPDATE-INFO] Available Memory (GB): ${AVAILABLE_MEMORY}"
        else
            echo "[HELK-UPDATE-ERROR] YOU DO NOT HAVE ENOUGH AVAILABLE MEMORY"
            echo "[HELK-UPDATE-ERROR] Available Memory (GB): ${AVAILABLE_MEMORY}"
            echo "[HELK-UPDATE-ERROR] Check the requirements section in our installation Wiki"
            echo "[HELK-UPDATE-ERROR] Installation Wiki: https://github.com/Cyb3rWard0g/HELK/wiki/Installation"
            exit 1
        fi
    else
        echo "[HELK-UPDATE-INFO] Error retrieving memory info for $systemKernel. Make sure you have at least 12GB of available memory!"
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

    if HELK_REPO_EXISTS=$(git remote | grep "helk-repo") && [ -z "$HELK_REPO_EXISTS" ]; then
        git remote add helk-repo https://github.com/Cyb3rWard0g/HELK.git  >> $LOGFILE 2>&1 
    else
        echo "HELK repo exists" >> $LOGFILE 2>&1
    fi

    git checkout master >> $LOGFILE 2>&1

    if PULL_NEEDED=$(git rev-list --left-right --count origin/master...helk-repo/master | awk '{print $2}') && [ ! "$PULL_NEEDED" == "0" ]; then
        echo "New release available. Commit diff --> $PULL_NEEDED" >> $LOGFILE 2>&1
        echo "[HELK-UPDATE-INFO] New release available. Pulling new code."
        git pull helk-repo master >> $LOGFILE 2>&1
        ERROR=$?
        if [ $ERROR -ne 0 ]; then
            echo "[!] Could not run pull latest code (Error Code: $ERROR). Check $LOGFILE for details."
            exit 1
        fi
        REBUILD_NEEDED=1
    else
        echo "[HELK-UPDATE-INFO] No updates available."    
    fi
}

get_jupyter_token(){
    echo "[HELK-UPDATE-INFO] Waiting for HELK services and Jupyter Server to start.."
    until curl -s localhost:8880 -o /dev/null; do
        sleep 1
    done
    jupyter_token="$(docker exec -ti helk-jupyter jupyter notebook list | grep -oP '(?<=token=).*(?= ::)' | awk '{$1=$1};1')" >> $LOGFILE 2>&1
    echo "[HELK-UPDATE-INFO] New Jupyter token: $jupyter_token"   
}

LOGFILE="/var/log/helk-update.log"
REBUILD_NEEDED=0

check_github

if [ $REBUILD_NEEDED == 1 ]; then
    echo -e "[HELK-UPDATE-INFO] Stopping HELK and starting update"
    docker-compose down >> $LOGFILE 2>&1
    check_min_requirements

    echo "[HELK-UPDATE-INFO] Rebuilding HELK via docker-compose"
    docker-compose up --build -d -V --force-recreate --always-recreate-deps >> $LOGFILE 2>&1
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echo "[!] Could not run HELK via docker-compose (Error Code: $ERROR). Check $LOGFILE for details."
        exit 1
    fi

    sleep 180
    get_jupyter_token
    echo -e "[HELK-UPDATE-INFO] YOUR HELK HAS BEEN UPDATED!"
else
    echo -e "[HELK-UPDATE-INFO] YOUR HELK IS ALREADY UP-TO-DATE."
fi
