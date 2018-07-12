#!/bin/bash

# HELK script: helk_install.sh
# HELK script description: Start
# HELK build Stage: Alpha
# HELK ELK version: 6.3.1
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# *********** Check if user is root ***************
if [[ $EUID -ne 0 ]]; then
   echo "[HELK-INSTALLATION-INFO] YOU MUST BE ROOT TO RUN THIS SCRIPT!!!" 
   exit 1
fi

LOGFILE="/var/log/helk-install.log"
echoerror() {
    printf "${RC} * ERROR${EC}: $@\n" 1>&2;
}

# ********** Check Minimum Requirements **************
check_min_requirements(){
    # *********** Check System Kernel Name ***************
    systemKernel="$(uname -s)"
    echo "[HELK-INSTALLATION-INFO] HELK being hosted on a $systemKernel box"
    if [ "$systemKernel" == "Linux" ]; then 
        AVAILABLE_MEMORY=$(awk '/MemAvailable/{printf "%.f", $2/1024/1024}' /proc/meminfo)
        ES_MEMORY=$(awk '/MemAvailable/{printf "%.f", $2/1024/1024/2}' /proc/meminfo)
        AVAILABLE_DISK=$(df -m | awk '$NF=="/"{printf "%.f\t\t", $4 / 1024}')    
        if [ "${AVAILABLE_MEMORY}" -ge "12" ] && [ "${AVAILABLE_DISK}" -ge "30" ]; then
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
        echo "[HELK-INSTALLATION-INFO] I could not calculate available memory or disk space for $systemKernel!!!!!"
        echo "[HELK-INSTALLATION-INFO] Make sure you have at least 12GB of available memory!!!!!!"
        echo "[HELK-INSTALLATION-INFO] Make sure you have at least 50GB of available disk space!!!!!"
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
    # ****** Building & running HELK ***********
    echo "[HELK-INSTALLATION-INFO] Building & running HELK via docker-compose"
    echo "[HELK-INSTALLATION-INFO] Using docker-compose-elk-${license_choice}.yml file"
    docker-compose -f docker-compose-elk-${license_choice}.yml up --build -d >> $LOGFILE 2>&1
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
        if [ -x "$(command -v snap)" ]; then
            SNAP_VERSION=$(snap version | grep -w 'snap' | awk '{print $2}')
            echo "[HELK-INSTALLATION-INFO] Snap v$SNAP_VERSION is available. Trying to install docker via snap.."
            snap install docker >> $LOGFILE 2>&1
            ERROR=$?
            if [ $ERROR -ne 0 ]; then
                echoerror "Could not install docker via snap (Error Code: $ERROR)."
                exit 1
            fi
            echo "[HELK-INSTALLATION-INFO] Docker successfully installed via snap."            
        else
            echo "[HELK-INSTALLATION-INFO] Docker could not be installed. Check /var/log/helk-install.log for details."
            exit 1
        fi
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
    read -t 30 -p "[HELK-INSTALLATION-INFO] Set HELK IP. Default value is your current IP: " -e -i ${host_ip} ip_choice
    host_ip="${ip_choice:-$host_ip}"
}

set_helk_license(){    
    # *********** Accepting Defaults or Allowing user to set HELK IP ***************
    local license_input
    read -t 30 -p "[HELK-INSTALLATION-INFO] Set HELK License. Default value is basic: " -e -i "basic" license_input
    license_choice=${license_input:-"basic"}
    # *********** Validating License Input ***************
    case $license_choice in
        basic)
        ;;
        trial)
        ;;
        *)
            echo "[HELK-INSTALLATION-ERROR] Not a valid license. Valid Options: basic or trial"
            exit 1
        ;;
    esac
}

prepare_helk(){
    echo "[HELK-INSTALLATION-INFO] HELK IP set to ${host_ip}"
    echo "[HELK-INSTALLATION-INFO] HELK License set to ${license_choice}"
    if [ "$systemKernel" == "Linux" ]; then
        # Reference: https://get.docker.com/
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
            echo "[HELK-INSTALLATION-INFO] Please innstall Docker & Docker-compose for $systemKernel"
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
    sed -i "s/ADVERTISED_LISTENER=HOSTIP/ADVERTISED_LISTENER=$host_ip/g" docker-compose-elk-${license_choice}.yml

    echo "[HELK-INSTALLATION-INFO] Setting ES_JAVA_OPTS value..."
    # ****** Setting ES JAVA OPTS environment variable ***********
    sed -i "s/ES_JAVA_OPTS\=\-Xms6g \-Xmx6g/ES_JAVA_OPTS\=\-Xms${ES_MEMORY}g \-Xmx${ES_MEMORY}g/g" docker-compose-elk-${license_choice}.yml
}

show_banner(){
    # *********** Showing HELK Docker menu options ***************
    echo " "
    echo "**********************************************"	
    echo "**          HELK - THE HUNTING ELK          **"
    echo "**                                          **"
    echo "** Author: Roberto Rodriguez (@Cyb3rWard0g) **"
    echo "** HELK build version: v0.1.1-alpha07062018 **"
    echo "** HELK ELK version: 6.3.1                  **"
    echo "** License: GPL-3.0                         **"
    echo "**********************************************"
    echo " "
}

show_final_information(){
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
}

manual_install(){
    show_banner
    check_min_requirements
    get_host_ip
    set_helk_ip
    set_helk_license
    prepare_helk
    install_helk
    get_jupyter_token
    sleep 180
    show_final_information
}

automatic_install(){
    show_banner
    check_min_requirements
    prepare_helk
    install_helk
    get_jupyter_token
    sleep 180
    show_final_information
}

usage(){
    echo
    echo "Usage: $0 [option...]" >&2
    echo
    echo "   -i         set HELKs IP address"
    echo "   -l         set HELKs License (basic or trial)"
    echo "   -q         quiet -> not output to the console"
    echo
    echo "Examples:"
    echo " $0                                   Install HELK manually"
    echo " $0 -i 192.168.64.131 -l basic        Install HELK with an IP address set and basic License"
    echo " $0 -i 192.168.64.131 -l trial -q     Install HELK with an IP address set and trial License without sending output to the console"
    echo
    exit 1
}

# ************ Start HELK Install **********************
# ************ Command Options **********************
while getopts ":i:l:q" opt; do
    case ${opt} in
        i )
            host_ip=$OPTARG
            ;;
        q )
            quiet="TRUE"
            ;;
        l )
            license_choice=$OPTARG
            ;;
        \? )
            echo "[HELK-INSTALLATION-ERROR] Invalid option: $OPTARG" 1>&2
            usage
            ;;
        : )
            echo "[HELK-INSTALLATION-ERROR] Invalid option: $OPTARG requires an argument" 1>&2
            usage
        ;;
    esac
done
shift $((OPTIND -1))
if [ $# -gt 0 ]; then
    echo "[HELK-INSTALLATION-ERROR] Invalid option"
    usage
fi
if [ -z "$host_ip" ] &&  [ -z "$quiet" ] && [ -z "$license_choice" ]; then
    manual_install
else
    if [[ "$host_ip" =~ ^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$ ]]; then
        for i in 1 2 3 4; do
            if [ $(echo "$host_ip" | cut -d. -f$i) -gt 255 ]; then
                echo "[HELK-INSTALLATION-ERROR] $host_ip is not a valid IP Address"
                usage
            fi
        done
        # *********** Validating License Input ***************
        case $license_choice in
            basic)
            ;;
            trial)
            ;;
            *)
                echo "[HELK-INSTALLATION-ERROR] Not a valid license. Valid Options: basic or trial"
                usage
            ;;
        esac
        # *********** Quiet or verbose ***************
        if [ -z "$quiet" ]; then
            automatic_install
        else
            automatic_install >> $LOGFILE 2>&1
        fi
    else
        echo "[HELK-INSTALLATION-ERROR] Invalid option"
        usage
    fi
fi