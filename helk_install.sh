#!/bin/bash

# HELK script: helk_install.sh
# HELK script description: Start
# HELK build version: 0.9 (Alpha)
# HELK ELK version: 6.1.3
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

# *********** Check if user is root ***************
if [[ $EUID -ne 0 ]]; then
   echo "[HELK-INSTALLATION-INFO] YOU MUST BE ROOT TO RUN THIS SCRIPT!!!" 
   exit 1
fi

LOGFILE="/var/log/helk-install.log"
echoerror() {
    printf "${RC} * ERROR${EC}: $@\n" 1>&2;
}

# *********** Check System Kernel Name ***************
systemKernel="$(uname -s)"

# *********** Pulling latest HELK image from DockerHub ***************
one(){
    echo "[HELK-DOCKER-INSTALLATION-INFO] Pulling the latest HELK image from Dockerhub.."
    docker pull cyb3rward0g/helk >> $LOGFILE 2>&1
    echo "[HELK-DOCKER-INSTALLATION-INFO] Running the HELK container in the background.."
    docker run -d -p 80:80 -p 5044:5044 -p 8880:8880 -p 4040:4040 -p 2181:2181 -p 9092:9092 -p 9093:9093 -p 9094:9094 -e "bootstrap.memory_lock=true" -e ADVERTISED_LISTENER="${host_ip}" --ulimit memlock=-1:-1 --name helk cyb3rward0g/helk >> $LOGFILE 2>&1

    # *********** Getting Jupyter Token ***************
    echo "[HELK-DOCKER-INSTALLATION-INFO] Waiting for HELK services and Jupyter Server to start.."
    until curl -s localhost:8880 -o /dev/null; do
        sleep 1
    done
    jupyter_token="$(docker exec -ti helk jupyter notebook list | grep -oP '(?<=token=).*(?= ::)' | awk '{$1=$1};1')" >> $LOGFILE 2>&1
    docker_access="HELK DOCKER BASH ACCESS: sudo docker exec -ti helk bash"
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not pull latest HELK image from Dockerhub (Error Code: $ERROR)."
        exit 1
    fi
}

# *********** Building HELK image from local Dockerfile ***************
two(){
    echo "[HELK-DOCKER-INSTALLATION-INFO] Building the HELK container from local Dockerfile.."
    docker build -t my_helk . >> $LOGFILE 2>&1
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not build HELK image from local Dockerfile (Error Code: $ERROR)."
        exit 1
    fi
    echo "[HELK-DOCKER-INSTALLATION-INFO] Running the HELK container in the background.."
    docker run -d -p 80:80 -p 5044:5044 -p 8880:8880 -p 4040:4040 -p 2181:2181 -p 9092:9092 -p 9093:9093 -p 9094:9094 -e "bootstrap.memory_lock=true" -e ADVERTISED_LISTENER="${host_ip}" --ulimit memlock=-1:-1 --name helk my_helk  >> $LOGFILE 2>&1

    # *********** Getting Jupyter Token ***************
    echo "[HELK-DOCKER-INSTALLATION-INFO] Waiting for HELK services and Jupyter Server to start.."
    until curl -s localhost:8880 -o /dev/null; do
        sleep 1
    done
    jupyter_token="$(docker exec -ti helk jupyter notebook list | grep -oP '(?<=token=).*(?= ::)' | awk '{$1=$1};1')" >> $LOGFILE 2>&1
    docker_access="HELK DOCKER BASH ACCESS: sudo docker exec -ti helk bash"
}

# *********** Building the HELK from local bash script ***************
three(){
    echo "[HELK-BASH-INSTALLATION-INFO] Installing the HELK from local bash script"
    cd scripts/
    ./helk_debian_tar_install.sh
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not build HELK image from bash script (Error Code: $ERROR)."
        exit 1
    fi
    jupyter_token=" First, run the following: source ~/.bashrc && pyspark"
}
 
# *********** Showing HELK Docker menu options ***************
show_menus() {
    echo " "
	echo "**********************************************"	
	echo "**           HELK - M E N U                 **"
    echo "**                                          **"
    echo "** Author: Roberto Rodriguez (@Cyb3rWard0g) **"
    echo "** HELK build version: 0.9 (Alpha)          **"
    echo "** HELK ELK version: 6.1.3                  **"
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
    if [ $choice = "1" ] || [ $choice = "2" ]; then
        if [ "$systemKernel" == "Linux" ]; then
            # Reference: https://get.docker.com/
            echo "[HELK-DOCKER-INSTALLATION-INFO] HELK identified Linux as the system kernel"
            echo "[HELK-DOCKER-INSTALLATION-INFO] Checking distribution list and version"
            # *********** Check distribution list ***************
            lsb_dist="$(. /etc/os-release && echo "$ID")"
            lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"

            # *********** Check distribution version ***************
            case "$lsb_dist" in
                ubuntu)
                    if [ -x "$(command -v lsb_release)" ]; then
                        dist_version="$(lsb_release --codename | cut -f2)"
                    fi
                    if [ -z "$dist_version" ] && [ -r /etc/lsb-release ]; then
                        dist_version="$(. /etc/lsb-release && echo "$DISTRIB_CODENAME")"
                    fi
                ;;
                debian|raspbian)
                    dist_version="$(sed 's/\/.*//' /etc/debian_version | sed 's/\..*//')"
                    case "$dist_version" in
                        9)
                            dist_version="stretch"
                        ;;
                        8)
                            dist_version="jessie"
                        ;;
                        7)
                            dist_version="wheezy"
                        ;;
                    esac
                ;;
                centos)
                    if [ -z "$dist_version" ] && [ -r /etc/os-release ]; then
                        dist_version="$(. /etc/os-release && echo "$VERSION_ID")"
                    fi
                ;;
                rhel|ol|sles)
                    ee_notice "$lsb_dist"
                    exit 1
                    ;;
                *)
                    if [ -x "$(command -v lsb_release)"]; then
                        dist_version="$(lsb_release --release | cut -f2)"
                    fi
                    if [ -z "$dist_version" ] && [ -r /etc/os-release ]; then
                        dist_version="$(. /etc/os-release && echo "$VERSION_ID")"
                    fi
                ;;
            esac
            echo "[HELK-DOCKER-INSTALLATION-INFO] You're using $lsb_dist version $dist_version"
            
            ERROR=$?
            if [ $ERROR -ne 0 ]; then
                echoerror "Could not verify distribution or version of the OS (Error Code: $ERROR)."
            fi

            # *********** Check if docker is installed ***************
            if [ -x "$(command -v docker)" ]; then
                echo "[HELK-DOCKER-INSTALLATION-INFO] Docker already installed"
                echo "[HELK-DOCKER-INSTALLATION-INFO] Dockerizing HELK.."
            else
                echo "[HELK-DOCKER-INSTALLATION-INFO] Docker is not installed"
                echo "[HELK-DOCKER-INSTALLATION-INFO] Checking if curl is installed first"
                if [ -x "$(command -v curl)" ]; then
                    echo "[HELK-DOCKER-INSTALLATION-INFO] curl is already installed"
                    echo "[HELK-DOCKER-INSTALLATION-INFO] Ready to install  Docker.."
                else
                    echo "[HELK-DOCKER-INSTALLATION-INFO] curl is not installed"
                    echo "[HELK-DOCKER-INSTALLATION-INFO] Installing curl before installing docker.."
                    apt-get install -y curl >> $LOGFILE 2>&1
                    ERROR=$?
                    if [ $ERROR -ne 0 ]; then
                        echoerror "Could not install curl (Error Code: $ERROR)."
                        exit 1
                    fi
                fi
                # ****** Installing via convenience script ***********
                echo "[HELK-DOCKER-INSTALLATION-INFO] Installing docker via convenience script.."
                curl -fsSL get.docker.com -o scripts/get-docker.sh >> $LOGFILE 2>&1
                chmod +x scripts/get-docker.sh >> $LOGFILE 2>&1
                scripts/get-docker.sh >> $LOGFILE 2>&1
                ERROR=$?
                if [ $ERROR -ne 0 ]; then
                    echoerror "Could not install docker via convenience script (Error Code: $ERROR)."
                    exit 1
                fi
            fi
        else
            # *********** Check if docker is installed ***************
            if [ -x "$(command -v docker)" ]; then
                echo "[HELK-DOCKER-INSTALLATION-INFO] Docker already installed"
                echo "[HELK-DOCKER-INSTALLATION-INFO] Dockerizing HELK.."
            else
                echo "[HELK-DOCKER-INSTALLATION-INFO] Install docker for $systemKernel"
                exit 1
            fi
        fi
    fi
    echo "[HELK-INSTALLATION-INFO] Checking local vm.max_map_count variable and setting it to 262144"
    MAX_MAP_COUNT=262144
    if [ -n "$MAX_MAP_COUNT" -a -f /proc/sys/vm/max_map_count ]; then
        sysctl -q -w vm.max_map_count=$MAX_MAP_COUNT >> $LOGFILE 2>&1
        ERROR=$?
        if [ $ERROR -ne 0 ]; then
            echoerror "Could not set vm.max_map_count to 262144 (Error Code: $ERROR)."
        fi
    fi
	case $choice in
		1) one ;;
		2) two ;;
        3) three ;;
		4) exit 0;;
		*) echo -e "[HELK-INSTALLATION-INFO] Wrong choice..." && exit 1
	esac
}

# *********** Getting Host IP ***************
# https://github.com/Invoke-IR/ACE/blob/master/ACE-Docker/start.sh
echo "[HELK-INSTALLATION-INFO] Obtaining current host IP.."
case "${systemKernel}" in
    Linux*)     host_ip=$(ip route get 1 | awk '{print $NF;exit}');;
    Darwin*)    host_ip=$(ifconfig en0 | grep inet | grep -v inet6 | cut -d ' ' -f2);;
    *)          host_ip="UNKNOWN:${unameOut}"
esac

# *********** Running selected option ***************
show_menus
read_options

echo " "
echo " "
echo " "
echo "***********************************************************************************"
echo "** [HELK-INSTALLATION-INFO] YOUR HELK IS READY                                   **"
echo "** [HELK-INSTALLATION-INFO] USE THE FOLLOWING SETTINGS TO INTERACT WITH THE HELK **"
echo "***********************************************************************************"
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