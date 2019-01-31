#!/bin/bash

# HELK script: helk_install.sh
# HELK script description: HELK installation
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# *********** Check if user is root ***************
if [[ $EUID -ne 0 ]]; then
   echo "[HELK-INSTALLATION-INFO] YOU MUST BE ROOT TO RUN THIS SCRIPT!!!" 
   exit 1
fi

# *********** Set Log File ***************
LOGFILE="/var/log/helk-install.log"
echoerror() {
    printf "${RC} * ERROR${EC}: $@\n" 1>&2;
}

# ********* Globals **********************
SYSTEM_KERNEL="$(uname -s)"

# ********** Check Minimum Requirements **************
check_min_requirements(){
    # *********** Check System Kernel Name ***************
    echo "[HELK-INSTALLATION-INFO] HELK being hosted on a $SYSTEM_KERNEL box"
    if [ "$SYSTEM_KERNEL" == "Linux" ]; then 
        AVAILABLE_MEMORY=$(awk '/MemAvailable/{printf "%.f", $2/1024/1024}' /proc/meminfo)
        AVAILABLE_DISK=$(df -m | awk '$NF=="/"{printf "%.f\t\t", $4 / 1024}')
        ARCHITECTURE=$(uname -m)
        if [ "${ARCHITECTURE}" != "x86_64" ]; then
            echo "[HELK-INSTALLATION-ERROR] HELK REQUIRES AN X86_64 BASED OPERATING SYSTEM TO INSTALL"
            echo "[HELK-INSTALLATION-ERROR] Your Systems Architecture: ${ARCHITECTURE}"
            echo "[HELK-INSTALLATION-ERROR] Check the requirements section in our installation Wiki"
            echo "[HELK-INSTALLATION-ERROR] Installation Wiki: https://github.com/Cyb3rWard0g/HELK/wiki/Installation"
            exit 1
        fi
        if [ "${AVAILABLE_MEMORY}" -ge "11" ] && [ "${AVAILABLE_DISK}" -ge "25" ]; then
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
        echo "[HELK-INSTALLATION-INFO] I could not calculate available memory or disk space for $SYSTEM_KERNEL!!!!!"
        echo "[HELK-INSTALLATION-INFO] Make sure you have at least 10GB of available memory!!!!!!"
        echo "[HELK-INSTALLATION-INFO] Make sure you have at least 25GB of available disk space!!!!!"
    fi
}

check_system_info(){
    echo "[HELK-INSTALLATION-INFO] Checking distribution list and product version"
    if [ "$SYSTEM_KERNEL" == "Linux" ]; then
        # *********** Check distribution list ***************
        LSB_DIST="$(. /etc/os-release && echo "$ID")"
        LSB_DIST="$(echo "$LSB_DIST" | tr '[:upper:]' '[:lower:]')"
        # *********** Check distribution version ***************
        case "$LSB_DIST" in
            ubuntu)
                if [ -x "$(command -v lsb_release)" ]; then
                    DIST_VERSION="$(lsb_release --codename | cut -f2)"
                fi
                if [ -z "$DIST_VERSION" ] && [ -r /etc/lsb-release ]; then
                    DIST_VERSION="$(. /etc/lsb-release && echo "$DISTRIB_CODENAME")"
                fi
                # ********* Commenting Out CDROM **********************
                sed -i "s/\(^deb cdrom.*$\)/\#/g" /etc/apt/sources.list
            ;;
            debian|raspbian)
                DIST_VERSION="$(sed 's/\/.*//' /etc/debian_version | sed 's/\..*//')"
                case "$DIST_VERSION" in
                    9) DIST_VERSION="stretch";;
                    8) DIST_VERSION="jessie";;
                    7) DIST_VERSION="wheezy";;
                esac
                # ********* Commenting Out CDROM **********************
                sed -i "s/\(^deb cdrom.*$\)/\#/g" /etc/apt/sources.list
            ;;
            centos)
                if [ -z "$DIST_VERSION" ] && [ -r /etc/os-release ]; then
                    DIST_VERSION="$(. /etc/os-release && echo "$VERSION_ID")"
                fi
            ;;
            rhel|ol|sles)
                ee_notice "$LSB_DIST"
                exit 1
                ;;
            *)
                if [ -x "$(command -v lsb_release)" ]; then
                    DIST_VERSION="$(lsb_release --release | cut -f2)"
                fi
                if [ -z "$DIST_VERSION" ] && [ -r /etc/os-release ]; then
                    DIST_VERSION="$(. /etc/os-release && echo "$VERSION_ID")"
                fi
            ;;
        esac           
        ERROR=$?
        if [ $ERROR -ne 0 ]; then
            echoerror "Could not verify distribution or version of the OS (Error Code: $ERROR)."
        fi
        echo "[HELK-INSTALLATION-INFO] You're using $LSB_DIST version $DIST_VERSION" 
    elif [ "$SYSTEM_KERNEL" == "Darwin" ]; then
        PRODUCT_NAME="$(sw_vers -productName)"
        PRODUCT_VERSION="$(sw_vers -productVersion)"
        BUILD_VERSION="$(sw_vers -buildVersion)"
        echo "[HELK-INSTALLATION-INFO] You're using $PRODUCT_NAME version $PRODUCT_VERSION"
    else
        echo "[HELK-INSTALLATION-INFO] We cannot figure out the SYSTEM_KERNEL, distribution or version of the OS"
    fi
}

# ********** Install Curl ********************
install_curl(){      
    echo "[HELK-INSTALLATION-INFO] Installing curl before installing docker.."
    case "$LSB_DIST" in
        ubuntu|debian|raspbian)
            apt install -y curl >> $LOGFILE 2>&1
        ;;
        centos|rhel)
            yum install curl >> $LOGFILE 2>&1
        ;;
        *)
            echo "[HELK-INSTALLATION-INFO] Please install curl for $LSB_DIST $DIST_VERSION.."
            exit 1
        ;;
    esac
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install curl for $LSB_DIST $DIST_VERSION (Error Code: $ERROR)."
        exit 1
    fi
}

# ********* Install htpasswd ********************
install_htpasswd(){
    if [ "$SYSTEM_KERNEL" == "Linux" ]; then
        echo "[HELK-INSTALLATION-INFO] Installing htpasswd .."
        case "$LSB_DIST" in
            ubuntu|debian|raspbian)
                apt install -y apache2-utils>> $LOGFILE 2>&1
            ;;
            centos|rhel)
                yum install httpd-tools >> $LOGFILE 2>&1
            ;;
            *)
                echo "[HELK-INSTALLATION-INFO] Please install htpasswd for $LSB_DIST $DIST_VERSION.."
                exit 1
            ;;
        esac
        ERROR=$?
        if [ $ERROR -ne 0 ]; then
            echoerror "Could not install htpasswd for $LSB_DIST $DIST_VERSION (Error Code: $ERROR)."
            exit 1
        fi
    else
        echo "[HELK-INSTALLATION-INFO] Please install htpasswd for $SYSTEM_KERNEL.."
    fi
}

# ****** Installing docker via convenience script ***********
install_docker(){
    echo "[HELK-INSTALLATION-INFO] Installing docker via convenience script.."
    curl -fsSL https://get.docker.com -o get-docker.sh >> $LOGFILE 2>&1
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

# ****** Installing docker compose from github.com/docker/compose ***********
install_docker_compose(){
    echo "[HELK-INSTALLATION-INFO] Installing docker-compose.."
    curl -L https://github.com/docker/compose/releases/download/1.23.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose >> $LOGFILE 2>&1
    chmod +x /usr/local/bin/docker-compose >> $LOGFILE 2>&1
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install docker-compose (Error Code: $ERROR)."
        exit 1
    fi
}

# *********** Set helk elasticsearch password ******************************
set_elasticsearch_password(){
    if [[ -z "$ELASTICSEARCH_PASSWORD_INPUT" ]] && [[ $SUBSCRIPTION_CHOICE == "trial" ]]; then
        while true; do
            read -t 30 -p "[HELK-INSTALLATION-INFO] Set HELK Elasticsearch Password: " -e -i "elasticpassword" ELASTICSEARCH_PASSWORD_INPUT
            READ_INPUT=$?
            ELASTICSEARCH_PASSWORD_INPUT=${ELASTICSEARCH_PASSWORD_INPUT:-"elasticpassword"}
            if [ $READ_INPUT = 142 ]; then
                echo -e "\n[HELK-INSTALLATION-INFO] HELK elasticsearch password set to ${ELASTICSEARCH_PASSWORD_INPUT}"
                break
            else
                read -p "[HELK-INSTALLATION-INFO] Verify HELK Elasticsearch Password: " ELASTICSEARCH_PASSWORD_INPUT_VERIFIED
                echo -e "[HELK-INSTALLATION-INFO] HELK elasticsearch password set to ${ELASTICSEARCH_PASSWORD_INPUT}"
                # *********** Validating Password Input ***************
                if [[ "$ELASTICSEARCH_PASSWORD_INPUT" == "$ELASTICSEARCH_PASSWORD_INPUT_VERIFIED" ]]; then 
                    break
                else
                    echo -e "${RED}Error...${STD}"
                    echo "[HELK-INSTALLATION-INFO] Your password values do not match.."
                fi
            fi
        done
        export ELASTIC_PASSWORD=$ELASTICSEARCH_PASSWORD_INPUT
    elif [[ "$ELASTICSEARCH_PASSWORD_INPUT" ]] && [[ $SUBSCRIPTION_CHOICE == "trial" ]]; then
        export ELASTIC_PASSWORD=$ELASTICSEARCH_PASSWORD_INPUT
    fi
}

# *********** Set helk kibana UI password ******************************
set_kibana_ui_password(){
    if [[ -z "$KIBANA_UI_PASSWORD_INPUT" ]]; then
        while true; do
            read -t 30 -p "[HELK-INSTALLATION-INFO] Set HELK Kibana UI Password: " -e -i "hunting" KIBANA_UI_PASSWORD_INPUT
            READ_INPUT=$?
            KIBANA_UI_PASSWORD_INPUT=${KIBANA_UI_PASSWORD_INPUT:-"hunting"}
            if [ $READ_INPUT = 142 ]; then
                echo -e "\n[HELK-INSTALLATION-INFO] HELK Kibana UI password set to ${KIBANA_UI_PASSWORD_INPUT}"
                break
            else
                read -p "[HELK-INSTALLATION-INFO] Verify HELK Kibana UI Password: " KIBANA_UI_PASSWORD_INPUT_VERIFIED
                echo -e "[HELK-INSTALLATION-INFO] HELK Kibana UI password set to ${KIBANA_UI_PASSWORD_INPUT}"
                # *********** Validating Password Input ***************
                if [[ "$KIBANA_UI_PASSWORD_INPUT" == "$KIBANA_UI_PASSWORD_INPUT_VERIFIED" ]]; then 
                    break
                else
                    echo -e "${RED}Error...${STD}"
                    echo "[HELK-INSTALLATION-INFO] Your password values do not match.."
                fi
            fi
        done
    fi
    if [[ $SUBSCRIPTION_CHOICE == "basic" ]]; then
        # *********** Check if htpasswd is installed ***************
        if ! [ -x "$(command -v htpasswd)" ]; then
            echo "[HELK-INSTALLATION-INFO] htpasswd is not installed"
            install_htpasswd
        fi
        mv helk-nginx/htpasswd.users helk-nginx/htpasswd.users_backup >> $LOGFILE 2>&1
        htpasswd -b -c helk-nginx/htpasswd.users "helk" $KIBANA_UI_PASSWORD_INPUT >> $LOGFILE 2>&1
        ERROR=$?
        if [ $ERROR -ne 0 ]; then
            echoerror "Could not add helk to htpasswd.users file (Error Code: $ERROR)."
            exit 1
        fi
    elif [[ $SUBSCRIPTION_CHOICE == "trial" ]]; then
        export KIBANA_UI_PASSWORD=$KIBANA_UI_PASSWORD_INPUT
    else
        echo "[HELK-INSTALLATION-INFO] Subscription Choise MUST be provided first.."
        exit 1
    fi
}

# *********** Set HELK network settings ***************
set_network(){
    if [[ -z "$HOST_IP" ]]; then
        # *********** Getting Host IP ***************
        # https://github.com/Invoke-IR/ACE/blob/master/ACE-Docker/start.sh
        echo "[HELK-INSTALLATION-INFO] Obtaining current host IP.."
        case "${SYSTEM_KERNEL}" in
            Linux*)     HOST_IP=$(ip route get 1 | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | tail -1);;
            Darwin*)    HOST_IP=$(ifconfig en0 | grep inet | grep -v inet6 | cut -d ' ' -f2);;
            *)          HOST_IP="UNKNOWN:${SYSTEM_KERNEL}"
        esac
        # *********** Accepting Defaults or Allowing user to set the HELK IP ***************
        local ip_choice
        read -t 30 -p "[HELK-INSTALLATION-INFO] Set HELK IP. Default value is your current IP: " -e -i ${HOST_IP} ip_choice
        READ_INPUT=$?
        HOST_IP="${ip_choice:-$HOST_IP}"
        if [ $READ_INPUT  = 142 ]; then
            echo -e "\n[HELK-INSTALLATION-INFO] HELK IP set to ${HOST_IP}"
        else
            echo "[HELK-INSTALLATION-INFO] HELK IP set to ${HOST_IP}"
        fi
    fi
}

# *********** Building and Running HELK Images ***************
build_helk(){
    COMPOSE_CONFIG="${HELK_BUILD}-${SUBSCRIPTION_CHOICE}.yml"
    ## ****** Setting KAFKA ADVERTISED_LISTENER environment variable ***********
    export ADVERTISED_LISTENER=$HOST_IP

    echo "[HELK-INSTALLATION-INFO] Building & running HELK from $COMPOSE_CONFIG file.."
    docker-compose -f $COMPOSE_CONFIG up --build -d >> $LOGFILE 2>&1
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not run HELK via docker-compose file $COMPOSE_CONFIG (Error Code: $ERROR)."
        exit 1
    fi
}

# *********** Asking user for Basic or Trial subscription of ELK ***************
set_helk_subscription(){
    if [[ -z "$SUBSCRIPTION_CHOICE" ]]; then
        # *********** Accepting Defaults or Allowing user to set HELK subscription ***************
        while true; do
            local subscription_input
            read -t 30 -p "[HELK-INSTALLATION-INFO] Set HELK elastic subscription (basic or trial): " -e -i "basic" subscription_input
            READ_INPUT=$?
            SUBSCRIPTION_CHOICE=${subscription_input:-"basic"}
            if [ $READ_INPUT = 142 ]; then
                echo -e "\n[HELK-INSTALLATION-INFO] HELK elastic subscription set to ${SUBSCRIPTION_CHOICE}"
                break
            else
                echo "[HELK-INSTALLATION-INFO] HELK elastic subscription set to ${SUBSCRIPTION_CHOICE}"
                # *********** Validating subscription Input ***************
                case $SUBSCRIPTION_CHOICE in
                    basic) break;;
                    trial) break;;
                    *)
                        echo -e "${RED}Error...${STD}"
                        echo "[HELK-INSTALLATION-ERROR] Not a valid subscription. Valid Options: basic or trial"
                    ;;
                esac
            fi
        done
    fi
}

# *********** Asking user for docker compose config ***************
set_helk_build(){
    if [[ -z "$HELK_BUILD" ]]; then
        while true; do
            echo " "
            echo "*****************************************************"	
            echo "*      HELK - Docker Compose Build Choices          *"
            echo "*****************************************************"
            echo " "
            echo "1. KAFKA + KSQL + ELK + NGNIX + ELASTALERT                   "
            echo "2. KAFKA + KSQL + ELK + NGNIX + ELASTALERT + SPARK + JUPYTER "
            echo " "

            local CONFIG_CHOICE
            read -t 30 -p "Enter build choice [ 1 - 2]: " -e -i "1" CONFIG_CHOICE
            READ_INPUT=$?
            HELK_BUILD=${CONFIG_CHOICE:-"helk-kibana-analysis"}
            if [ $READ_INPUT = 142 ]; then
                echo -e "\n[HELK-INSTALLATION-INFO] HELK build set to ${HELK_BUILD}"
                break
            else
                echo "[HELK-INSTALLATION-INFO] HELK build set to ${HELK_BUILD}"
                case $CONFIG_CHOICE in
                    1) HELK_BUILD='helk-kibana-analysis';break ;;
                    2) HELK_BUILD='helk-kibana-notebook-analysis';break;;
                    *) 
                        echo -e "${RED}Error...${STD}"
                        echo "[HELK-INSTALLATION-ERROR] Not a valid build"
                    ;;
                esac
            fi
        done
    fi
}

# *********** Install and set up pre-requirements ***************
prepare_helk(){
    if [ "$SYSTEM_KERNEL" == "Linux" ]; then
        # *********** Check if curl is installed ***************
        if ! [ -x "$(command -v curl)" ]; then
            echo "[HELK-INSTALLATION-INFO] curl is not installed"
            install_curl
        fi
        # *********** Check if docker is installed ***************
        if [ -x "$(command -v docker)" ]; then
            echo "[HELK-INSTALLATION-INFO] Docker already installed"
            echo "[HELK-INSTALLATION-INFO] Making sure you assigned enough disk space to the current Docker base directory"
            AVAILABLE_DOCKER_DISK=$(df -m $(docker info --format '{{.DockerRootDir}}') | awk '$1 ~ /\//{printf "%.f\t\t", $4 / 1024}')    
            if [ "${AVAILABLE_DOCKER_DISK}" -ge "25" ]; then
                echo "[HELK-INSTALLATION-INFO] Available Docker Disk: $AVAILABLE_DOCKER_DISK"
            else
                echo "[HELK-INSTALLATION-ERROR] YOU DO NOT HAVE ENOUGH DOCKER DISK SPACE ASSIGNED"
                echo "[HELK-INSTALLATION-ERROR] Available Docker Disk: $AVAILABLE_DOCKER_DISK"
                echo "[HELK-INSTALLATION-ERROR] Check the requirements section in our installation Wiki"
                echo "[HELK-INSTALLATION-ERROR] Installation Wiki: https://github.com/Cyb3rWard0g/HELK/wiki/Installation"
                exit 1
            fi
        else
            echo "[HELK-INSTALLATION-INFO] Docker is not installed"
            install_docker
        fi
        # ********** Check if docker-compose is installed *******
        if ! [ -x "$(command -v docker-compose)" ]; then
            echo "[HELK-INSTALLATION-INFO] Docker-compose is not installed"
            install_docker_compose
        fi
    else
        # *********** Check if docker is installed ***************
        if ! [ -x "$(command -v docker)" ] && ! [ -x "$(command -v docker-compose)" ]; then
            echo "[HELK-INSTALLATION-INFO] Please innstall Docker & Docker-compose for $SYSTEM_KERNEL"
            exit 1
        fi
    fi

    # *********** Checking internal set up ***************
    echo "[HELK-INSTALLATION-INFO] Checking local vm.max_map_count variable and setting it to 262144"
    MAX_MAP_COUNT=262144
    if [ -n "$MAX_MAP_COUNT" -a -f /proc/sys/vm/max_map_count ]; then
        sysctl -q -w vm.max_map_count=$MAX_MAP_COUNT >> $LOGFILE 2>&1
        ERROR=$?
        if [ $ERROR -ne 0 ]; then
            echoerror "Could not set vm.max_map_count to 262144 (Error Code: $ERROR)."
        fi
        echo "vm.max_map_count = $MAX_MAP_COUNT" > /etc/sysctl.d/90-helk-overwritten-during-docker-install-sysctl-tuning.conf;
    fi
}

get_jupyter_credentials(){
    if [[ ${HELK_BUILD} == "helk-kibana-notebook-analysis" ]]; then
        until  docker exec -ti helk-jupyter cat /opt/helk/user_credentials.txt ; do
            sleep 10
        done
    fi
}

show_banner(){
    # *********** Showing HELK Docker menu options ***************
    echo " "
    echo "**********************************************"	
    echo "**          HELK - THE HUNTING ELK          **"
    echo "**                                          **"
    echo "** Author: Roberto Rodriguez (@Cyb3rWard0g) **"
    echo "** HELK build version: v0.1.6-alpha01312019 **"
    echo "** HELK ELK version: 6.5.4                  **"
    echo "** License: GPL-3.0                         **"
    echo "**********************************************"
    echo " "
}

show_final_information(){
    echo " "
    echo " "
    echo "***********************************************************************************"
    echo "** [HELK-INSTALLATION-INFO] HELK WAS INSTALLED SUCCESSFULLY                      **"
    echo "** [HELK-INSTALLATION-INFO] USE THE FOLLOWING SETTINGS TO INTERACT WITH THE HELK **"
    echo "***********************************************************************************"
    echo " "
    if [[ ${HELK_BUILD} == "helk-kibana-notebook-analysis" ]]; then
        echo "HELK KIBANA URL: https://${HOST_IP}"
        echo "HELK KIBANA USER: helk"
        echo "HELK KIBANA PASSWORD: ${KIBANA_UI_PASSWORD_INPUT}"
        echo "HELK SPARK MASTER UI: http://${HOST_IP}:8080"
        echo "HELK JUPYTERHUB URL: http://${HOST_IP}/jupyter"
        get_jupyter_credentials
    elif [[ ${HELK_BUILD} == "helk-kibana-analysis" ]]; then
        echo "HELK KIBANA URL: https://${HOST_IP}"
        echo "HELK KIBANA USER: helk"
        echo "HELK KIBANA PASSWORD: ${KIBANA_UI_PASSWORD_INPUT}"
    fi
    echo "HELK ZOOKEEPER: ${HOST_IP}:2181"
    echo "HELK KSQL SERVER: ${HOST_IP}:8088"
    echo " "
    echo "IT IS HUNTING SEASON!!!!!"
    echo " "
    echo " "
}

install_helk(){
    show_banner
    check_min_requirements
    check_system_info
    set_helk_build
    set_helk_subscription
    set_kibana_ui_password
    set_elasticsearch_password
    set_network
    prepare_helk
    build_helk
    sleep 180
    show_final_information
}

usage(){
    echo " "
    echo "Usage: $0 [option...]" >&2
    echo
    echo "   -p         set helk kibana ui password"
    echo "   -i         set HELKs IP address"
    echo "   -b         set HELKs build (helk-kibana-analysis OR helk-kibana-notebook-analysis)"
    echo "   -l         set HELKs subscription (basic or trial)"
    echo "   -e         set HELKs elasticsearch password"
    echo "   -q         quiet -> not output to the console"
    echo
    echo "Examples:"
    echo " $0                                                                                           Install HELK manually"
    echo " $0 -p As3gur@! -i 192.168.64.131 -b 'helk-kibana-analysis' -l 'basic'                        Install HELK with a basic subscription"
    echo " $0 -p As3gur@! -i 192.168.64.131 -b 'helk-kibana-analysis' -l 'trial'  -e elasticpasword     Install HELK with a trial subscription"
    echo " $0 -p As3gur@! -i 192.168.64.131 -b 'helk-kibana-analysis' -l 'basic'  -q                    Install HELK with a basic subscription quietly"
    echo " "
    exit 1
}

# ************ Start HELK Install **********************
# ************ Command Options **********************
while getopts p:i:b:l:eq option
do
    case "${option}"
    in
        p) KIBANA_UI_PASSWORD_INPUT=$OPTARG;;
        i) HOST_IP=$OPTARG;;
        b) HELK_BUILD=$OPTARG;;
        l) SUBSCRIPTION_CHOICE=$OPTARG;;
        e) ELASTICSEARCH_PASSWORD_INPUT=$OPTARG;;
        q) quiet="TRUE";;
        \?) usage;;
    esac
done

if [ -z "$KIBANA_UI_PASSWORD_INPUT" ] && [ -z "$HOST_IP" ] && [ -z "$HELK_BUILD" ] && [ -z "$SUBSCRIPTION_CHOICE" ]; then
    install_helk
else
    if [[ "$HOST_IP" =~ ^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$ ]]; then
        for i in 1 2 3 4; do
            if [ $(echo "$HOST_IP" | cut -d. -f$i) -gt 255 ]; then
                echo "[HELK-INSTALLATION-ERROR] $HOST_IP is not a valid IP Address"
                usage
            fi
        done
        # *********** Validating subscription Input ***************
        case $SUBSCRIPTION_CHOICE in
            basic);;
            trial);;
            *)
                echo "[HELK-INSTALLATION-ERROR] Not a valid subscription. Valid Options: basic or trial"
                usage
            ;;
        esac
        # *********** Validating helk build***************
        case $HELK_BUILD in
            helk-kibana-analysis);;
            helk-kibana-notebook-analysis);;
            *)
                echo "[HELK-INSTALLATION-ERROR] Not a valid build. Valid Options: kafka, helk-kibana-analysis OR helk-kibana-notebook-analysis "
                usage
            ;;
        esac
        # *********** Quiet or verbose ***************
        if [[ -z "$quiet" ]]; then
            install_helk
        else
            install_helk >> $LOGFILE 2>&1
        fi
    else
        echo "[HELK-INSTALLATION-ERROR] Make sure you set the right parameters"
        usage
    fi
fi