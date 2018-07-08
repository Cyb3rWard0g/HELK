#!/bin/bash

# HELK script: helk_update.sh
# HELK script description: Update and Rebuild HELK
# HELK build version: 0.9 (Alpha)
# HELK ELK version: 6.3.0
# Script Author: Dev Dua (@devdua)
# License: BSD 3-Clause

if [[ $EUID -ne 0 ]]; then
   echo "[HELK-UPDATE-INFO] YOU MUST BE ROOT TO RUN THIS SCRIPT!!!" 
   exit 1
fi

usage(){
    echo "Usage: $0 [option...]" >&2
    echo -e "\t-s\t\tSet update source"
    echo -e "\t\t\t 1: Github (Stable, Recommended)"
    echo -e "\t\t\t 2: Docker Hub"
    exit 1
}

check_min_requirements(){
    systemKernel="$(uname -s)"
    echo "[HELK-UPDATE-INFO] HELK being hosted on a $systemKernel box"
    if [ "$systemKernel" == "Linux" ]; then 
        AVAILABLE_MEMORY=$(free -hm | awk 'NR==2{printf "%.f\t\t", $7 }')
        
        # Only checking Available Memory requirements and not Disk, as old images are deleted and replaced with updated ones.
        if [ "${AVAILABLE_MEMORY}" -ge "12" ] ; then
            echo "[HELK-UPDATE-INFO] Available Memory (GB): ${AVAILABLE_MEMORY}"
        else
            echo "[HELK-UPDATE-ERROR] YOU DO NOT HAVE ENOUGH AVAILABLE MEMORY"
            echo "[HELK-UPDATE-ERROR] Available Memory (GB): ${AVAILABLE_MEMORY}"
            echo "[HELK-UPDATE-ERROR] Check the requirements section in our installation Wiki"
            echo "[HELK-UPDATE-ERROR] Installation Wiki: https://github.com/Cyb3rWard0g/HELK/wiki/Installation"
            mv docker-compose.yml.bak docker-compose.yml >> $LOGFILE 2>&1
            rm docker-compose.yml.bak >> $LOGFILE 2>&1
            exit 1
        fi
    else
        echo "[HELK-UPDATE-INFO] Error retrieving memory info for $systemKernel. Make sure you have at least 12GB of available memory!"
    fi
}

check_docker_hub(){
    echo "[WARNING] Pulling updated images from Docker Hub may lead to an unstable deployment of the HELK, as it may not match the recommended & tested configuration posted in the Github repository."
    if [ -x "$(command -v python)" ]; then
        echo "Python is available" >> $LOGFILE
    else
        echo "Python is not available" >> $LOGFILE
        apt-get -qq update >> $LOGFILE 2>&1 && apt-get -qqy install python >> $LOGFILE 2>&1
        ERROR=$?
        if [ $ERROR -ne 0 ]; then
            echo "[!] Could not install Python (Error Code: $ERROR). Check $LOGFILE for details."
            exit 1
        fi
        echo "Python installed." >> $LOGFILE
    fi

    for image in $HELK_IMAGES$EXTENSION_IMAGES
    do
        TAG=$(sudo docker images | grep $image | awk '{print $2}')
        SIZE=$(sudo docker images | grep $image | awk '{print $7}')
        echo -e "Local tag for $image --> $TAG | Size : $SIZE" >> $LOGFILE 2>&1
        REMOTE_TAG="$(curl --silent "https://hub.docker.com/v2/repositories/$image/tags/" | python -c 'import sys, json; print (json.load(sys.stdin)["results"][0]["name"])')"    
        
        REMOTE_FULLSIZE="$(curl --silent "https://hub.docker.com/v2/repositories/$image/tags/" | python -c 'import sys, json; print (json.load(sys.stdin)["results"][0]["full_size"])')"
        MB=$((1024*1024))
        REMOTE_FULLSIZE_MB=$(($REMOTE_FULLSIZE/$MB))
        echo -e "Remote tag for $image --> $REMOTE_TAG | Size : $REMOTE_FULLSIZE_MB MB\n" >> $LOGFILE 2>&1

        [ "$TAG" = "$REMOTE_TAG" ] ; SHOULD_UPDATE=$?
        if [ $SHOULD_UPDATE == "0" ]; then
            echo "[+] $image is up to date"
        else
            REBUILD_NEEDED=1
            docker rmi -f "$image:$TAG" >> $LOGFILE 2>&1
            cp docker-compose.yml docker-compose.yml.bak
            sed -i "s|$image:$TAG|$image:$REMOTE_TAG|" docker-compose.yml >> $LOGFILE 2>&1
            ERROR=$?
            if [ $ERROR -ne 0 ]; then
                echo "[!] Could not update the HELK (Error Code: $ERROR). Check $LOGFILE for details."
                echo "This could happen if 2 or more images for $image with different tags exist together. Please delete the image not being used by a running HELK container and try again."
                mv docker-compose.yml.bak docker-compose.yml >> $LOGFILE 2>&1
                rm docker-compose.yml.bak >> $LOGFILE 2>&1
                exit 1
            fi
            echo -e "[+] Newer tag for $image found --> $REMOTE_TAG (current: $TAG) | Size --> $REMOTE_FULLSIZE_MB MB (current expanded size: $SIZE)."
        fi
    done
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
HELK_IMAGES=$(docker images --format "{{.Repository}}" | grep "cyb3rward0g/helk-")
# Extension images not hosted by cyb3rward0g
EXTENSION_IMAGES=" thomaspatzke/helk-sigma"
REBUILD_NEEDED=0
SOURCES=("GITHUB" "DOCKER HUB")
UPDATE_FUNCTIONS=(check_github check_docker_hub)

if [ -z "$1" ]; then
    usage
fi

while getopts ":s:h" opt; do
  case $opt in
    s)  if [ "$OPTARG" == "1" -o "$OPTARG" == "2" ]; then
            echo "Chosen update source --> ${SOURCES[$OPTARG-1]}" >> $LOGFILE 2>&1
            echo "[HELK-UPDATE-INFO] CHECKING ${SOURCES[$OPTARG-1]} FOR UPDATES."
            ${UPDATE_FUNCTIONS[$OPTARG-1]}
        else
            echo "[!] Invalid update source option"
            usage
        fi
        ;;
    h)  usage
        ;;
    \?) echo "[!] Invalid option: -$OPTARG" >&2
        usage
        ;;
    :)  echo "[!] Option -$OPTARG requires an argument." >&2
        usage
        ;;
    esac
done

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
    rm docker-compose.yml.bak >> $LOGFILE 2>&1
else
    echo -e "[HELK-UPDATE-INFO] YOUR HELK IS ALREADY UP-TO-DATE."
fi
chmod 666 docker-compose.yml  >> $LOGFILE 2>&1