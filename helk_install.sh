#!/bin/bash

# HELK script: helk_install.sh
# HELK script description: Start
# HELK build version: 0.9 (Alpha)
# HELK ELK version: 6.2.3
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

# ********** Check Minimum Requirements **************
check_min_requirements(){
    echo "[HELK-INSTALLATION-INFO] HELK being hosted on a $systemKernel box"
    if [ "$systemKernel" == "Linux" ]; then 
        AVAILABLE_MEMORY=$(free -hm | awk 'NR==2{printf "%.f\t\t", $4 }')
        ES_MEMORY=$(free -hm | awk 'NR==2{printf "%.f", $4/2 }')
        AVAILABLE_DISK=$(df -h | awk '$NF=="/"{printf "%.f\t\t", $4}')
        
        if [ "${AVAILABLE_MEMORY}" -ge "10" ] && [ "${AVAILABLE_DISK}" -ge "30" ]; then
            echo "[HELK-INSTALLATION-INFO] Available Memory: $AVAILABLE_MEMORY"
            echo "[HELK-INSTALLATION-INFO] Available Disk: $AVAILABLE_DISK"
        else
            echo "[HELK-INSTALLATION-ERROR] YOU DO NOT HAVE ENOUGH AVAILABLE MEMORY OR DISK SPACE"
            echo "[HELK-INSTALLATION-ERROR] Available Memory: $AVAILABLE_MEMORY"
            echo "[HELK-INSTALLATION-ERROR] Available Disk: $AVAILABLE_DISK"
            echo "[HELK-INSTALLATION-ERROR] Check the requirements section in our installation Wiki"
            echo "[HELK-INSTALLATION-ERROR] Installation Wiki: https://github.com/Cyb3rWard0g/HELK/wiki/Installation"
            exit 1
        fi
    else
        echo "[HELK-INSTALLATION-INFO] Make sure you have at least 12GB of available memory!!!!!!"
        echo "[HELK-INSTALLATION-INFO] Make sure you have at least 50GB of available disk space!!!!!"
        echo "[HELK-INSTALLATION-INFO] I could not calculate available memory or disk space for $systemKernel!!!!!"
    fi
}

# *********** Getting Jupyter Token ***************
get_jupyter_token(){
    echo "[HELK-INSTALLATION-INFO] Waiting for HELK services and Jupyter Server to start.."
    until curl -s localhost:8880 -o /dev/null; do
        sleep 1
    done
    jupyter_token="$(docker exec -ti helk-jupyter jupyter notebook list | grep -oP '(?<=token=).*(?= ::)' | awk '{$1=$1};1')" >> $LOGFILE 2>&1
}

# ********** Install Curl ********************
install_curl(){
    echo "[HELK-INSTALLATION-INFO] Checking if curl is installed first"
    if [ -x "$(command -v curl)" ]; then
        echo "[HELK-INSTALLATION-INFO] curl is already installed"
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
}

# *********** Building and Running HELK Images ***************
install_helk(){
    echo "[HELK-INSTALLATION-INFO] Building HELK via docker-compose"

    # ****** Building HELK ***********
    docker-compose build >> $LOGFILE 2>&1
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not build HELK via docker-compose (Error Code: $ERROR)."
        echo "get more details in /var/log/helk-install.log locally"
        exit 1
    fi
    
    # ****** Running HELK ***********
    echo "[HELK-INSTALLATION-INFO] Running HELK via docker-compose"
    docker-compose up -d >> $LOGFILE 2>&1
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not run HELK via docker-compose (Error Code: $ERROR)."
        exit 1
    fi
}

# ****** Installing via convenience script ***********
install_docker(){
    echo "[HELK-INSTALLATION-INFO] Installing docker via convenience script.."
    curl -fsSL get.docker.com -o get-docker.sh >> $LOGFILE 2>&1
    chmod +x get-docker.sh >> $LOGFILE 2>&1
    ./get-docker.sh >> $LOGFILE 2>&1
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install docker via convenience script (Error Code: $ERROR)."
        exit 1
    fi
}

install_docker_compose(){
    echo "[HELK-INSTALLATION-INFO] Installing docker-compose.."
    curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose >> $LOGFILE 2>&1
    chmod +x /usr/local/bin/docker-compose >> $LOGFILE 2>&1
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install docker-compose (Error Code: $ERROR)."
        exit 1
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
}

set_helk_ip(){    
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

prepare_helk(){
    get_host_ip
    set_helk_ip
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
            
        else
            echo "[HELK-INSTALLATION-INFO] Docker is not installed"

            # ****** Install Curl if it is not installed *********
            install_curl
            # ****** Installing Docker if it is not installed *********
            install_docker
        fi
        # ********** Check if docker-compose is installed *******
        if [ -x "$(command -v docker-compose)" ]; then
            echo "[HELK-INSTALLATION-INFO] Docker-compose already installed"
        else
            echo "[HELK-INSTALLATION-INFO] Docker-compose is not installed"

            # ****** Install Curl if it is not installed *********
            install_curl
            # ****** Installing Docker-Compose *******************
            install_docker_compose
        fi
    else
        # *********** Check if docker is installed ***************
        if [ -x "$(command -v docker)" ] && [ -x "$(command -v docker-compose)" ]; then
            echo "[HELK-INSTALLATION-INFO] Docker & Docker-compose already installed"
        else
            echo "[HELK-INSTALLATION-INFO] Install Docker & Docker-compose for $systemKernel"
            exit 1
        fi
    fi
    echo "[HELK-INSTALLATION-INFO] Dockerizing HELK.."
    echo "[HELK-INSTALLATION-INFO] Checking local vm.max_map_count variable and setting it to 262144"
    MAX_MAP_COUNT=262144
    if [ -n "$MAX_MAP_COUNT" -a -f /proc/sys/vm/max_map_count ]; then
        sysctl -q -w vm.max_map_count=$MAX_MAP_COUNT >> $LOGFILE 2>&1
        ERROR=$?
        if [ $ERROR -ne 0 ]; then
            echoerror "Could not set vm.max_map_count to 262144 (Error Code: $ERROR)."
        fi
    fi

    echo "[HELK-INSTALLATION-INFO] Setting KAFKA ADVERTISED_LISTENER value..."
    # ****** Setting KAFKA ADVERTISED_LISTENER environment variable ***********
    sed -i "s/ADVERTISED_LISTENER=HOSTIP/ADVERTISED_LISTENER=$host_ip/g" docker-compose.yml

    echo "[HELK-INSTALLATION-INFO] Setting ES_JAVA_OPTS value..."
    # ****** Setting ES JAVA OPTS environment variable ***********
    sed -i "s/ES_JAVA_OPTS\=\-XmsMEMg \-XmxMEMg/ES_JAVA_OPTS\=\-Xms${ES_MEMORY}g \-Xmx${ES_MEMORY}g/g" docker-compose.yml
}

# *********** Showing HELK Docker menu options ***************
echo " "
echo "**********************************************"	
echo "**          HELK - THE HUNTING ELK          **"
echo "**                                          **"
echo "** Author: Roberto Rodriguez (@Cyb3rWard0g) **"
echo "** HELK build version: 0.9 (Alpha)          **"
echo "** HELK ELK version: 6.2.4                  **"
echo "** License: BSD 3-Clause                    **"
echo "**********************************************"
echo " "

# *********** Running selected option ***************
check_min_requirements
prepare_helk
install_helk
get_jupyter_token
sleep 180

echo " "
echo " "
echo "***********************************************************************************"
echo "** [HELK-INSTALLATION-INFO] YOUR HELK IS READY                                   **"
echo "** [HELK-INSTALLATION-INFO] USE THE FOLLOWING SETTINGS TO INTERACT WITH THE HELK **"
echo "***********************************************************************************"
echo " "
echo "HELK KIBANA URL: http://${host_ip}"
echo "HELK KIBANA & ELASTICSEARCH USER: helk"
echo "HELK KIBANA & ELASTICSEARCH PASSWORD: hunting"
echo "HELK JUPYTER CURRENT TOKEN: ${jupyter_token}"
echo "HELK JUPYTER LAB URL: http://${host_ip}:8880/lab"
echo "HELK SPARK Pyspark UI: http://${host_ip}:4040"
echo "HELK SPARK Cluster Master UI: http://${host_ip}:8080"
echo "HELK SPARK Cluster Worker1 UI: http://${host_ip}:8081"
echo "HELK SPARK Cluster Worker2 UI: http://${host_ip}:8082"
echo " "
echo "IT IS HUNTING SEASON!!!!!"
echo " "
echo " "
echo " "
