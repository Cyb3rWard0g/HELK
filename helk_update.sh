#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "[HELK-UPDATE-INFO] YOU MUST BE ROOT TO RUN THIS SCRIPT!!!" 
   exit 1
fi

LOGFILE="/var/log/helk-update.log"
HELK_IMAGES=$(docker images --format "{{.Repository}}" | grep "cyb3rward0g/helk-")
REBUILD_NEEDED=0

echo -e "[HELK-UPDATE-INFO] CHECKING FOR UPDATES..."

if [ -x "$(command -v python)" ]; then
    echo "Python is available" >> $LOGFILE
else
    echo "Python is not available" >> $LOGFILE
    apt-get update  >> $LOGFILE 2>&1 && apt-get -qqy install python >> $LOGFILE 2>&1
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install Python (Error Code: $ERROR)."
        exit 1
    fi
    echo "Python installed." >> $LOGFILE
fi

for image in $HELK_IMAGES
do
    TAG=$(sudo docker images | grep $image | awk '{print $2}')
    echo -e "Tag for $image --> $TAG" >> $LOGFILE 2>&1
    REMOTE_TAG="$(curl --silent "https://hub.docker.com/v2/repositories/$image/tags/" | python -c 'import sys, json; print (json.load(sys.stdin)["results"][0]["name"])')"
    [ "$TAG" = "$REMOTE_TAG" ] ; SHOULD_UPDATE=$?
    if [ $SHOULD_UPDATE == "0" ]; then
        echo "[+] $image is up to date"
    else
        REBUILD_NEEDED=1
        echo -e "[+] Newer tag for $image found --> $REMOTE_TAG (current: $TAG)."
        echo -e "[HELK-UPDATE-INFO] Stopping HELK and pulling new image for $image."
        sed -i "s|$image:$TAG|$image:$REMOTE_TAG|" docker-compose.yml
        ERROR=$?
        if [ $ERROR -ne 0 ]; then
            echo "Could not update the HELK (Error Code: $ERROR)."
            echo "This could happen if 2 or more images for $image with different tags exist together. Please delete the image not being used by a running HELK container and try again."
            exit 1
        fi
        docker-compose stop >> $LOGFILE 2>&1
        docker-compose down >> $LOGFILE 2>&1
        docker rmi -f "$image:$TAG" >> $LOGFILE 2>&1
    fi
done

get_jupyter_token(){
    echo "[HELK-UPDATE-INFO] Waiting for HELK services and Jupyter Server to start.."
    until curl -s localhost:8880 -o /dev/null; do
        sleep 1
    done
    jupyter_token="$(docker exec -ti helk-jupyter jupyter notebook list | grep -oP '(?<=token=).*(?= ::)' | awk '{$1=$1};1')" >> $LOGFILE 2>&1
    echo "[HELK-UPDATE-INFO] New Jupyter token: $jupyter_token"   
}

if [ $REBUILD_NEEDED == 1 ]; then
    docker-compose build >> $LOGFILE 2>&1
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echo "Could not build HELK via docker-compose (Error Code: $ERROR)."
        echo "Get more details in /var/log/helk-update.log"
        exit 1
    fi

    # ****** Running HELK ***********
    echo "[HELK-UPDATE-INFO] Running HELK via docker-compose"
    docker-compose up -d --force-recreate --always-recreate-deps >> $LOGFILE 2>&1
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echo "Could not run HELK via docker-compose (Error Code: $ERROR)."
        exit 1
    fi
    get_jupyter_token
    sleep 180
    echo -e "\n[HELK-UPDATE-INFO] YOUR HELK HAS BEEN UPDATED!"
else
    echo -e "\n[HELK-UPDATE-INFO] YOUR HELK IS ALREADY UP-TO-DATE."
fi