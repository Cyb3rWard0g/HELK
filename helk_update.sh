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

    if [[ -z "$(git remote | grep helk-repo)" ]]; then
        git remote add helk-repo https://github.com/Cyb3rWard0g/HELK.git  >> $LOGFILE 2>&1 
    else
        echo "HELK repo exists" >> $LOGFILE 2>&1
    fi

    if COMMIT_DIFF=$(git rev-list --count master...helk-repo/master) && [ ! "$COMMIT_DIFF" == "0" ]; then
        echo "Possibly new release available. Commit diff --> $COMMIT_DIFF" >> $LOGFILE 2>&1
        IS_MASTER_BEHIND=$(git branch -v | grep master | grep behind)
        
        if [[ -z $IS_MASTER_BEHIND ]]; then
            echo "Current master branch ahead of remote branch. Exiting..." >> $LOGFILE 2>&1
            echo "[HELK-UPDATE-INFO] No updates available."
        else            
            echo "[HELK-UPDATE-INFO] New release available. Pulling new code."
            git checkout master >> $LOGFILE 2>&1
            git pull helk-repo master >> $LOGFILE 2>&1
            REBUILD_NEEDED=1
        fi
    else
        echo "[HELK-UPDATE-INFO] No updates available."    
    fi
}

get_jupyter_token(){
    until curl -s localhost:8880 -o /dev/null; do
        sleep 1
    done
    jupyter_token="$(docker exec -ti helk-jupyter jupyter notebook list | grep -oP '(?<=token=).*(?= ::)' | awk '{$1=$1};1')" >> $LOGFILE 2>&1
    echo "[HELK-UPDATE-INFO] New Jupyter token: $jupyter_token"   
}

LOGFILE="/var/log/helk-update.log"
REBUILD_NEEDED=0

echo "[HELK-UPDATE-INFO] Checking GitHub for updates..."   
check_github

if [ $REBUILD_NEEDED == 1 ]; then
    set_helk_license
    echo -e "[HELK-UPDATE-INFO] Stopping HELK and starting update"
    docker-compose -f docker-compose-elk-${license_choice}.yml down >> $LOGFILE 2>&1
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echo -e "[!] Could not stop HELK via docker-compose (Error Code: $ERROR). You're possibly running a different HELK license than chosen - $license_choice"
        exit 1
    fi

    check_min_requirements

    echo "[HELK-UPDATE-INFO] Rebuilding HELK via docker-compose"
    docker-compose -f docker-compose-elk-${license_choice}.yml up --build -d -V --force-recreate --always-recreate-deps >> $LOGFILE 2>&1
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echo -e "[!] Could not run HELK via docker-compose (Error Code: $ERROR). Check $LOGFILE for details."
        exit 1
    fi
    
    secs=$((3 * 60))
    while [ $secs -gt 0 ]; do
        echo -ne "\033[0K\r[HELK-UPDATE-INFO] Rebuild succeeded, waiting $secs seconds for services to start"
        sleep 1
        : $((secs--))
    done

    get_jupyter_token
    echo -e "[HELK-UPDATE-INFO] YOUR HELK HAS BEEN UPDATED!"
else
    echo -e "[HELK-UPDATE-INFO] YOUR HELK IS ALREADY UP-TO-DATE."
fi