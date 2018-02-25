#!/bin/bash

# HELK script: helk_install.sh
# HELK script description: Start
# HELK build version: 0.9 (Alpha)
# HELK ELK version: 6.2.2
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

# *********** Getting Jupyter Token ***************
get_token(){
    echo "[HELK-INSTALLATION-INFO] Waiting for HELK services and Jupyter Server to start.."
    until curl -s localhost:8880 -o /dev/null; do
        sleep 1
    done
    jupyter_token="$(docker exec -ti helk-analytics jupyter notebook list | grep -oP '(?<=token=).*(?= ::)' | awk '{$1=$1};1')" >> $LOGFILE 2>&1
}

# *********** Building and Running HELK Images ***************
build_run(){
    echo "[HELK-INSTALLATION-INFO] Installing HELK via docker-compose"
    echo "ADVERTISED_LISTENER=$host_ip" >> helk.env
    docker-compose up -d >> $LOGFILE 2>&1
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not build HELK via docker-compose (Error Code: $ERROR)."
        exit 1
    fi 
}
 
# *********** Showing HELK Docker menu options ***************
show_banner() {
    echo " "
	echo "**********************************************"	
	echo "**          HELK - THE HUNTING ELK          **"
    echo "**                                          **"
    echo "** Author: Roberto Rodriguez (@Cyb3rWard0g) **"
    echo "** HELK build version: 0.9 (Alpha)          **"
    echo "** HELK ELK version: 6.2.2                  **"
    echo "** License: BSD 3-Clause                    **"
    echo "**********************************************"
    echo " "
}

prepare_helk(){
    get_host_ip
    if [ "$systemKernel" == "Linux" ]; then
        # Reference: https://get.docker.com/
        echo "[HELK-INSTALLATION-INFO] HELK identified Linux as the system kernel"
        echo "[HELK-INSTALLATION-INFO] Checking distribution list and version"
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
        echo "[HELK-INSTALLATION-INFO] You're using $lsb_dist version $dist_version"            
        ERROR=$?
        if [ $ERROR -ne 0 ]; then
            echoerror "Could not verify distribution or version of the OS (Error Code: $ERROR)."
        fi

        # *********** Check if docker is installed ***************
        if [ -x "$(command -v docker)" ]; then
            echo "[HELK-INSTALLATION-INFO] Docker already installed"
            echo "[HELK-INSTALLATION-INFO] Dockerizing HELK.."
        else
            echo "[HELK-INSTALLATION-INFO] Docker is not installed"
            echo "[HELK-INSTALLATION-INFO] Checking if curl is installed first"
            if [ -x "$(command -v curl)" ]; then
                echo "[HELK-INSTALLATION-INFO] curl is already installed"
                echo "[HELK-INSTALLATION-INFO] Ready to install  Docker.."
            else
                echo "[HELK-INSTALLATION-INFO] curl is not installed"
                echo "[HELK-INSTALLATION-INFO] Installing curl before installing docker.."
                apt-get install -y curl >> $LOGFILE 2>&1
                ERROR=$?
                if [ $ERROR -ne 0 ]; then
                    echoerror "Could not install curl (Error Code: $ERROR)."
                    exit 1
                fi
            fi
            # ****** Installing via convenience script ***********
            echo "[HELK-INSTALLATION-INFO] Installing docker via convenience script.."
            curl -fsSL get.docker.com -o scripts/get-docker.sh >> $LOGFILE 2>&1
            chmod +x scripts/get-docker.sh >> $LOGFILE 2>&1
            scripts/get-docker.sh >> $LOGFILE 2>&1
            ERROR=$?
            if [ $ERROR -ne 0 ]; then
                echoerror "Could not install docker via convenience script (Error Code: $ERROR)."
                exit 1
            fi
            # ****** Installing docker-compose ***********
            echo "[HELK-INSTALLATION-INFO] Installing docker-compose .."
            curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose >> $LOGFILE 2>&1
            chmod +x /usr/local/bin/docker-compose >> $LOGFILE 2>&1
            ERROR=$?
            if [ $ERROR -ne 0 ]; then
                echoerror "Could not install docker-compose (Error Code: $ERROR)."
                exit 1
            fi
        fi
    else
        # *********** Check if docker is installed ***************
        if [ -x "$(command -v docker)" ]; then
            echo "[HELK-INSTALLATION-INFO] Docker already installed"
            echo "[HELK-INSTALLATION-INFO] Dockerizing HELK.."
        else
            echo "[HELK-INSTALLATION-INFO] Install docker for $systemKernel"
            exit 1
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
}

get_host_ip(){
    # *********** Getting Host IP ***************
    # https://github.com/Invoke-IR/ACE/blob/master/ACE-Docker/start.sh
    echo "[HELK-INSTALLATION-INFO] Obtaining current host IP.."
    case "${systemKernel}" in
        Linux*)     host_ip=$(ip route get 1 | awk '{print $NF;exit}');;
        Darwin*)    host_ip=$(ifconfig en0 | grep inet | grep -v inet6 | cut -d ' ' -f2);;
        *)          host_ip="UNKNOWN:${unameOut}"
    esac
    
    # *********** Accepting Defaults or Allowing user to set HELK IP ***************
    local ip_choice
    local read_input
    read -t 30 -p "[HELK-INSTALLATION-INFO] Set HELK IP. Default value is your current IP: " -e -i ${host_ip} ip_choice
    read_input=$?
    ip_choice="${ip_choice:-$host_ip}"
    if [ $ip_choice != $host_ip ]; then
        host_ip=$ip_choice
    fi
    if [ $read_input  = 142 ]; then
       echo -e "\n[HELK-INSTALLATION-INFO] HELK IP set to ${host_ip}" 
    else
    echo "[HELK-INSTALLATION-INFO] HELK IP set to ${host_ip}"
    fi
}

# *********** Running selected option ***************
show_banner
prepare_helk
build_run
get_token

echo " "
echo " "
echo "***********************************************************************************"
echo "** [HELK-INSTALLATION-INFO] YOUR HELK IS READY                                   **"
echo "** [HELK-INSTALLATION-INFO] USE THE FOLLOWING SETTINGS TO INTERACT WITH THE HELK **"
echo "***********************************************************************************"
echo " "
echo "HELK KIBANA URL: http://${host_ip}"
echo "HELK ELASTICSEARCH EXTERNAL URL: http://${host_ip}:8082"
echo "HELK CEREBRO URL: http://${host_ip}:9000"
echo "HELK KIBANA & ELASTICSEARCH USER: helk"
echo "HELK KIBANA & ELASTICSEARCH PASSWORD: hunting"
echo "HELK JUPYTER CURRENT TOKEN: ${jupyter_token}"
echo "HELK SPARK UI: http://${host_ip}:4040"
echo "HELK JUPYTER LAB URL: http://${host_ip}:8880/lab"
echo " "
echo "IT IS HUNTING SEASON!!!!!"
echo " "
echo " "
echo " "