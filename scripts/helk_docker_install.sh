#!/bin/bash

# HELK script: helk_docker_install.sh
# HELK script description: Installs Docker & Docker-Compose on your HELK server.
# HELK build version: 0.9 (BETA)
# HELK ELK version: 6.x
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

# References: 
#  https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-16-04
#  https://www.digitalocean.com/community/tutorials/how-to-install-docker-compose-on-ubuntu-16-04 

LOGFILE="/var/log/helk-docker-install.log"

echoerror() {
    printf "${RC} * ERROR${EC}: $@\n" 1>&2;
}

# *********** Installing Docker ***************
echo "[HELK DOCKER INSTALLATION INFO] Installing updates.."
apt-get update >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install updates (Error Code: $ERROR)."
    fi

echo "[HELK DOCKER INSTALLATION INFO] Adding the GPG key for the official Docker repository to the system.."
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not add the GPG key for the official Docker repository to the system.. (Error Code: $ERROR)."
    fi

echo "[HELK DOCKER INSTALLATION INFO] Installing updates.."
apt-get update >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install updates (Error Code: $ERROR)."
    fi

echo "[HELK DOCKER INSTALLATION INFO] Adding the docker repository to APT sources.."
apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main' >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not add the docker repository to APT sources.. (Error Code: $ERROR)."
    fi

echo "[HELK DOCKER INSTALLATION INFO] Updating the package database with the Docker packages from the newly added repo.."
apt-get update >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not update the package database with the Docker packages from the newly added repo.. (Error Code: $ERROR)."
    fi

echo "[HELK DOCKER INSTALLATION INFO] Making sure that Docker is being installed from the Docker repo and not the default Ubuntu 16.04 repo.."
apt-cache policy docker-engine >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "something went wrong.. (Error Code: $ERROR)."
    fi	

echo "[HELK DOCKER INSTALLATION INFO] Installing Docker.."
apt-get install -y docker-engine >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install Docker.. (Error Code: $ERROR)."
    fi

# *********** Installing Docker-Compose ***************
echo "[HELK DOCKER INSTALLATION INFO] Installing Docker-Compose.."	
curl -o /usr/local/bin/docker-compose -L "https://github.com/docker/compose/releases/download/1.13.0/docker-compose-$(uname -s)-$(uname -m)" >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install Docker.. (Error Code: $ERROR)."
    fi

echo "[HELK DOCKER INSTALLATION INFO] Setting permissions to the docker-compose binary.."
chmod +x /usr/local/bin/docker-compose >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not set permissions to the docker-compose binary.. (Error Code: $ERROR)."
    fi

echo "[HELK DOCKER INSTALLATION INFO] Docker & Docker-Compose have been successfully installed.."
echo "***********************************************"
echo "[HELK DOCKER INSTALLATION INFO] Docker Version:"
docker -v
echo "***********************************************"
echo "[HELK DOCKER INSTALLATION INFO] Docker-Compose Version:"
docker-compose -v



