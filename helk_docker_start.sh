#!/bin/bash

# HELK script: helk_docker_start.sh
# HELK script description: Start
# HELK build version: 0.9 (BETA)
# HELK ELK version: 6.x
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
   echo "[HELK-DOCKER-INSTALLATION-INFO] YOU MUST BE ROOT TO RUN THIS SCRIPT!!!" 
   exit 1
fi

# Check if docker is installed
if [ -x "$(command -v docker)" ]; then
    echo "[HELK-DOCKER-INSTALLATION-INFO] Docker already installed"
    echo "[HELK-DOCKER-INSTALLATION-INFO] Dockerizing HELK.."
else
    echo "[HELK-DOCKER-INSTALLATION-INFO] Installing docker first"
    scripts/helk_docker_install.sh
fi

# Build the HELK image from the DockerFile
echo "[HELK-DOCKER-INSTALLATION-INFO] Building the HELK container.."
docker build -t my_helk .
echo "[HELK-DOCKER-INSTALLATION-INFO] Running the HELK container in the background.."
docker run -d -p 80:80 -p 5044:5044 -p 8880:8880 -p 4040:4040 --name helk my_helk

echo " "
echo " "

#Get Host IP
echo "[HELK-DOCKER-INSTALLATION-INFO] Obtaining current host IP.."
host_ip="$(ip route get 1 | awk '{print $NF;exit}')"

#Get Jupyter Token
echo "[HELK-DOCKER-INSTALLATION-INFO] Waiting for Jupyter Server to start.."
until curl -s localhost:8880 -o /dev/null; do
    sleep 1
done
jupyter_token="$(docker exec -ti helk jupyter notebook list | grep -oP '(?<=token=).*(?= ::)' | awk '{$1=$1};1')"

echo " "
echo " "
echo " "
echo "**********************************************************************************************************"
echo "[HELK-DOCKER-INSTALLATION-INFO] YOUR HELK'S CONTAINER IS READY"
echo "[HELK-DOCKER-INSTALLATION-INFO] USE THE FOLLOWING SETTINGS TO INTERACT WITH THE HELK"
echo "**********************************************************************************************************"
echo " "
echo "HELK KIBANA URL: http://${host_ip}"
echo "HELK KIBANA USER: helk"
echo "HELK KIBANA PASSWORD: hunting"
echo "HELK SPARK UI: http://${host_ip}:4040"
echo "HELK JUPYTER NOTEBOOK URI: http://${host_ip}:8880"
echo "HELK JUPYTER CURRENT TOKEN: ${jupyter_token}"
echo "HELK DOCKER BASH ACCESS: sudo docker exec -ti helk bash"
echo " "
echo "IT IS HUNTING SEASON!!!!!"
echo " "
echo " "
echo " "