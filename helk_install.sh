#!/bin/bash

# HELK script: helk_docker_start.sh
# HELK script description: Start
# HELK build version: 0.9 (BETA)
# HELK ELK version: 6.x
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

# *********** Check if user is root ***************
if [[ $EUID -ne 0 ]]; then
   echo "[HELK-INSTALLATION-INFO] YOU MUST BE ROOT TO RUN THIS SCRIPT!!!" 
   exit 1
fi

# *********** Check System Kernel Name ***************
systemKernel="$(uname -s)"

# *********** Pulling latest HELK image from DockerHub ***************
one(){
	if [ "$systemKernel" == "Linux" ]; then
        # *********** Check if docker is installed ***************
        if [ -x "$(command -v docker)" ]; then
            echo "[HELK-DOCKER-INSTALLATION-INFO] Docker already installed"
            echo "[HELK-DOCKER-INSTALLATION-INFO] Dockerizing HELK.."
        else
            echo "[HELK-DOCKER-INSTALLATION-INFO] Installing docker first"
            scripts/helk_linux_deb_docker_install.sh
        fi
    else
        # *********** Check if docker is installed ***************
        if [ -x "$(command -v docker)" ]; then
            echo "[HELK-DOCKER-INSTALLATION-INFO] Docker already installed"
            echo "[HELK-DOCKER-INSTALLATION-INFO] Dockerizing HELK.."
        else
            echo "[HELK-DOCKER-INSTALLATION-INFO] Install docker first"
            exit 1
        fi
    fi

    echo "[HELK-DOCKER-INSTALLATION-INFO] Checking local vm.max_map_count variable"
    MAX_MAP_COUNT=262144
    if [ -n "$MAX_MAP_COUNT" -a -f /proc/sys/vm/max_map_count ]; then
        sysctl -q -w vm.max_map_count=$MAX_MAP_COUNT
    fi

    echo "[HELK-DOCKER-INSTALLATION-INFO] Building the HELK container from source.."
    docker pull cyb3rward0g/helk
    echo "[HELK-DOCKER-INSTALLATION-INFO] Running the HELK container in the background.."
    docker run -d -p 80:80 -p 5044:5044 -p 8880:8880 -p 4040:4040 --name helk cyb3rward0g/helk -e "bootstrap.memory_lock=true" --ulimit memlock=-1:-1

    # *********** Getting Jupyter Token ***************
    echo "[HELK-DOCKER-INSTALLATION-INFO] Waiting for Jupyter Server to start.."
    until curl -s localhost:8880 -o /dev/null; do
        sleep 1
    done
    jupyter_token="$(docker exec -ti helk jupyter notebook list | grep -oP '(?<=token=).*(?= ::)' | awk '{$1=$1};1')"
    docker_access="HELK DOCKER BASH ACCESS: sudo docker exec -ti helk bash"
}

# *********** Building HELK image from local Dockerfile ***************
two(){
    if [ "$systemKernel" == "Linux" ]; then
        # *********** Check if docker is installed ***************
        if [ -x "$(command -v docker)" ]; then
            echo "[HELK-DOCKER-INSTALLATION-INFO] Docker already installed"
            echo "[HELK-DOCKER-INSTALLATION-INFO] Dockerizing HELK.."
        else
            echo "[HELK-DOCKER-INSTALLATION-INFO] Installing docker first"
            scripts/helk_linux_deb_docker_install.sh
        fi
    else
        # *********** Check if docker is installed ***************
        if [ -x "$(command -v docker)" ]; then
            echo "[HELK-DOCKER-INSTALLATION-INFO] Docker already installed"
            echo "[HELK-DOCKER-INSTALLATION-INFO] Dockerizing HELK.."
        else
            echo "[HELK-DOCKER-INSTALLATION-INFO] Install docker first.."
            exit 1
        fi
    fi

    echo "[HELK-DOCKER-INSTALLATION-INFO] Checking local vm.max_map_count variable"
    MAX_MAP_COUNT=262144
    if [ -n "$MAX_MAP_COUNT" -a -f /proc/sys/vm/max_map_count ]; then
        sysctl -q -w vm.max_map_count=$MAX_MAP_COUNT
    fi

    echo "[HELK-DOCKER-INSTALLATION-INFO] Building the HELK container from local Dockerfile.."
    docker build -t my_helk .
    echo "[HELK-DOCKER-INSTALLATION-INFO] Running the HELK container in the background.."
    docker run -d -p 80:80 -p 5044:5044 -p 8880:8880 -p 4040:4040 --name helk my_helk -e "bootstrap.memory_lock=true" --ulimit memlock=-1:-1

    # *********** Getting Jupyter Token ***************
    echo "[HELK-DOCKER-INSTALLATION-INFO] Waiting for Jupyter Server to start.."
    until curl -s localhost:8880 -o /dev/null; do
        sleep 1
    done
    jupyter_token="$(docker exec -ti helk jupyter notebook list | grep -oP '(?<=token=).*(?= ::)' | awk '{$1=$1};1')"
    docker_access="HELK DOCKER BASH ACCESS: sudo docker exec -ti helk bash"
}

# *********** Building the HELK from local bash script ***************
three(){
    echo "[HELK-BASH-INSTALLATION-INFO] Installing the HELK from local bash script"
    echo "[HELK-BASH-INSTALLATION-INFO] Checking local vm.max_map_count variable"
    MAX_MAP_COUNT=262144
    if [ -n "$MAX_MAP_COUNT" -a -f /proc/sys/vm/max_map_count ]; then
        sysctl -q -w vm.max_map_count=$MAX_MAP_COUNT
    fi
    cd scripts/
    ./helk_linux_deb_install.sh
    jupyter_token=" First, run the following: source ~/.bashrc && pyspark"
}
 
# *********** Showing HELK Docker menu options ***************
show_menus() {
    echo " "
	echo "**********************************************"	
	echo "**           HELK - M E N U                 **"
    echo "**                                          **"
    echo "** Author: Roberto Rodriguez (@Cyb3rWard0g) **"
    echo "** HELK build version: 0.9 (BETA)           **"
    echo "** HELK ELK version: 6.x                    **"
    echo "** License: BSD 3-Clause                    **"
    echo "**********************************************"
    echo " "
	echo "1. Pull the latest HELK image from DockerHub"
	echo "2. Build the HELK image from local Dockerfile"
    echo "3. Install the HELK from local bash script"
    echo "4. Exit"
    echo " "
}

read_options(){
	local choice
	read -p "[HELK-INSTALLATION-INFO] Enter choice [ 1 - 4] " choice
	case $choice in
		1) one ;;
		2) two ;;
        3) three ;;
		4) exit 0;;
		*) echo -e "[HELK-INSTALLATION-INFO] Wrong choice..." && exit 1
	esac
}

# *********** Running selected option ***************
show_menus
read_options

# *********** Getting Host IP ***************
# https://github.com/Invoke-IR/ACE/blob/master/ACE-Docker/start.sh
echo "[HELK-DOCKER-INSTALLATION-INFO] Obtaining current host IP.."
case "${systemKernel}" in
    Linux*)     host_ip=$(ip route get 1 | awk '{print $NF;exit}');;
    Darwin*)    host_ip=$(ifconfig en0 | grep inet | grep -v inet6 | cut -d ' ' -f2);;
    *)          ip="UNKNOWN:${unameOut}"
esac

echo " "
echo " "
echo " "
echo "**********************************************************************************************************"
echo "[HELK-INSTALLATION-INFO] YOUR HELK IS READY"
echo "[HELK-INSTALLATION-INFO] USE THE FOLLOWING SETTINGS TO INTERACT WITH THE HELK"
echo "**********************************************************************************************************"
echo " "
echo "HELK KIBANA URL: http://${host_ip}"
echo "HELK KIBANA USER: helk"
echo "HELK KIBANA PASSWORD: hunting"
echo "HELK JUPYTER CURRENT TOKEN: ${jupyter_token}"
echo "HELK SPARK UI: http://${host_ip}:4040"
echo "HELK JUPYTER NOTEBOOK URI: http://${host_ip}:8880"
echo "${docker_access}"
echo " "
echo "IT IS HUNTING SEASON!!!!!"
echo " "
echo " "
echo " "