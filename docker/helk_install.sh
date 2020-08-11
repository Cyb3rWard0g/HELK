#!/bin/bash

# HELK script: helk_install.sh
# HELK script description: HELK installation
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

HELK_BUILD_VERSION="v0.1.9-alpha03272020"
HELK_ELK_VERSION="7.6.2"
SUBSCRIPTION_CHOICE="basic"

# *********** Helk log tagging variables ***************
# For more efficient script editing/reading, and also if/when we switch to different install script language
HELK_INFO_TAG="[HELK-INSTALLATION-INFO]"
HELK_ERROR_TAG="[HELK-INSTALLATION-ERROR]"
# Make sure to use "echo -e" with this variable
INSTALL_ERROR_CHECK_WIKI="$HELK_ERROR_TAG Check the requirements section in the Installation Wiki: https://github.com/Cyb3rWard0g/HELK/wiki/Installation"

# *********** Variables for user modification ***************
# Careful editing unless you know what you are doing :)
## In MBs
INSTALL_MINIMUM_MEMORY=5000
## In MBs
INSTALL_MINIMUM_MEMORY_NOTEBOOK=8000
## In GBs
INSTALL_MINIMUM_DISK=20
## Sysctl Parameters
SYSCTL_VM_MAX_MAP_COUNT=4120294
SYSCTL_VM_SWAPPINESS=25

# *********** Export variables to environment ***************
export DOCKER_CLIENT_TIMEOUT=300
export COMPOSE_HTTP_TIMEOUT=300
export SUBSCRIPTION_CHOICE=${SUBSCRIPTION_CHOICE}

# *********** Check if user is root ***************
if [[ $EUID -ne 0 ]]; then
  echo "$HELK_INFO_TAG YOU MUST BE ROOT TO RUN THIS SCRIPT!"
  exit 1
fi

# *********** Set Log File ***************
LOGFILE="/var/log/helk-install.log"
echoerror() {
    printf "${RC} * ERROR${EC}: $@\n" 1>&2;
}

# ********* Globals **********************
SYSTEM_KERNEL="$(uname -s)"
# Will output in MBs
AVAILABLE_MEMORY=$(awk '/MemAvailable/{printf "%.f", $2/1024}' /proc/meminfo)
TOTAL_MEMORY=$(awk '/MemTotal/{printf "%.f", $2/1024}' /proc/meminfo)
# HELK Directory
HELK_DIR="/usr/share/helk"
# HELK Configuration File
HELK_CONF_FILE="$HELK_DIR/helk.conf"
# HELK Information File for operating system
HELK_INFO_FILE="$HELK_DIR/helk_install.info"

HELK_GIT_BUILD=$(cat ../.git/refs/heads/master)

persist_conf() {
  if [ ! -d "$HELK_DIR" ]; then
    mkdir -p $HELK_DIR >>$LOGFILE 2>&1
  fi

  COMPOSE_CONFIG="${HELK_BUILD}-basic.yml"
  #TODO: add check if CentOS if selinux is enabled and if enforcement mode or note

  if [[ -f $HELK_CONF_FILE ]]; then
    #TODO:give choice to set these or just move completely to update script
    #SYSCTL_VM_MAX_MAP_COUNT=$(cat $HELK_CONF_FILE | grep SYSCTL_VM_MAX_MAP_COUNT | cut -d'=' -f2)
    #HOST_IP=$(cat $HELK_CONF_FILE | grep HOST_IP | cut -d'=' -f2)
    #HELK_BUILD=$(cat $HELK_CONF_FILE | grep HELK_BUILD | cut -d'=' -f2)
    #SUBSCRIPTION_CHOICE=$(cat $HELK_CONF_FILE | grep SUBSCRIPTION_CHOICE | cut -d'=' -f2)
    {
      sed -i -e "s/^SYSCTL_VM_MAX_MAP_COUNT[[:blank:]]*=[[:blank:]]*.*/SYSCTL_VM_MAX_MAP_COUNT=$SYSCTL_VM_MAX_MAP_COUNT/" $HELK_CONF_FILE
      sed -i -e "s/^SYSCTL_VM_SWAPPINESS[[:blank:]]*=[[:blank:]]*.*/SYSCTL_VM_SWAPPINESS=$SYSCTL_VM_SWAPPINESS/" $HELK_CONF_FILE
      sed -i -e "s/^HOST_IP[[:blank:]]*=[[:blank:]]*.*/HOST_IP=$HOST_IP/" $HELK_CONF_FILE
      sed -i -e "s/^HELK_BUILD[[:blank:]]*=[[:blank:]]*.*/HELK_BUILD=$HELK_BUILD/" $HELK_CONF_FILE
      sed -i -e "s/^SUBSCRIPTION_CHOICE[[:blank:]]*=[[:blank:]]*.*/SUBSCRIPTION_CHOICE=$SUBSCRIPTION_CHOICE/" $HELK_CONF_FILE
      sed -i -e "s/^COMPOSE_CONFIG[[:blank:]]*=[[:blank:]]*.*/COMPOSE_CONFIG=$COMPOSE_CONFIG/" $HELK_CONF_FILE
    } >> $LOGFILE 2>&1
  else
    touch $HELK_CONF_FILE >>$LOGFILE 2>&1
    {
      echo "SYSCTL_VM_MAX_MAP_COUNT=$SYSCTL_VM_MAX_MAP_COUNT"
      echo "SYSCTL_VM_SWAPPINESS=$SYSCTL_VM_SWAPPINESS"
      echo "HOST_IP=$HOST_IP"
      echo "HELK_BUILD=$HELK_BUILD"
      echo "SUBSCRIPTION_CHOICE=$SUBSCRIPTION_CHOICE"
      echo "COMPOSE_CONFIG=$COMPOSE_CONFIG"
    } >> $HELK_CONF_FILE 2>&1
  fi
}

set_install_info() {
  if [[ -e $HELK_INFO_FILE ]]; then
    rm $HELK_INFO_FILE
  fi
  {
    echo "INSTALLED_DATE=$(date -u)"
    echo "ARCHITECTURE=$ARCHITECTURE"
    echo "SYSTEM_KERNEL=$SYSTEM_KERNEL"
    echo "AVAILABLE_MEMORY=$AVAILABLE_MEMORY"
    echo "TOTAL_MEMORY=$TOTAL_MEMORY"
    echo "HELK_BUILD=$HELK_BUILD"
    echo "SUBSCRIPTION_CHOICE=$SUBSCRIPTION_CHOICE"
    echo "LSB_DIST=$LSB_DIST"
    echo "DIST_VERSION=$DIST_VERSION"
    echo "AVAILABLE_DOCKER_DISK=$AVAILABLE_DOCKER_DISK"
    echo "HELK_GIT_BUILD=$HELK_GIT_BUILD"
    echo "COMPOSE_CONFIG=$COMPOSE_CONFIG"
  } >> $HELK_INFO_FILE 2>&1
}
# ********** Check Minimum Requirements **************
check_min_requirements() {
  # *********** Check System Kernel Name ***************
  echo "$HELK_INFO_TAG HELK hosted on a $SYSTEM_KERNEL box"
  if [ "$SYSTEM_KERNEL" == "Linux" ]; then
    ARCHITECTURE=$(uname -m)
    if [ "${ARCHITECTURE}" != "x86_64" ]; then
      echo "$HELK_ERROR_TAG HELK REQUIRES AN X86_64 BASED OPERATING SYSTEM TO INSTALL"
      echo "Your Systems Architecture: ${ARCHITECTURE}"
      echo -e $INSTALL_ERROR_CHECK_WIKI
      exit 1
    fi
    if [[ "${AVAILABLE_MEMORY}" -ge $INSTALL_MINIMUM_MEMORY ]]; then
      echo "$HELK_INFO_TAG Available Memory: $AVAILABLE_MEMORY MBs"
    else
      echo "$HELK_ERROR_TAG YOU DO NOT HAVE ENOUGH AVAILABLE MEMORY"
      echo "$HELK_INFO_TAG This may be because you are already running the HELK docker containers.. If so, stop them and try again"
      echo "$HELK_ERROR_TAG Available Memory: $AVAILABLE_MEMORY MBs"
      echo -e $INSTALL_ERROR_CHECK_WIKI
      exit 1
    fi
  else
    echo "$HELK_ERROR_TAG I could not calculate available memory for $SYSTEM_KERNEL"
    echo "$HELK_ERROR_TAG Make sure you have at least $INSTALL_MINIMUM_MEMORY MBs of available memory"
  fi
}

check_system_info() {
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
    debian | raspbian)
      DIST_VERSION="$(sed 's/\/.*//' /etc/debian_version | sed 's/\..*//')"
      case "$DIST_VERSION" in
      9) DIST_VERSION="stretch" ;;
      8) DIST_VERSION="jessie" ;;
      7) DIST_VERSION="wheezy" ;;
      esac
      # ********* Commenting Out CDROM **********************
      sed -i "s/\(^deb cdrom.*$\)/\#/g" /etc/apt/sources.list
      ;;
    centos)
      if [ -z "$DIST_VERSION" ] && [ -r /etc/os-release ]; then
        DIST_VERSION="$(. /etc/os-release && echo "$VERSION_ID")"
      fi
      ;;
    rhel | ol | sles)
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
    echo "$HELK_INFO_TAG You're using $LSB_DIST version $DIST_VERSION"
  elif [ "$SYSTEM_KERNEL" == "Darwin" ]; then
    PRODUCT_NAME="$(sw_vers -productName)"
    PRODUCT_VERSION="$(sw_vers -productVersion)"
    BUILD_VERSION="$(sw_vers -buildVersion)"
    echo "$HELK_INFO_TAG You're using $PRODUCT_NAME version $PRODUCT_VERSION"
  else
    echo "$HELK_INFO_TAG We cannot figure out the SYSTEM_KERNEL, distribution or version of the OS"
  fi
}

# ********** Install Curl ********************
install_curl() {
  echo "$HELK_INFO_TAG Installing curl before installing docker.."
  case "$LSB_DIST" in
  ubuntu | debian | raspbian)
    apt install -y curl >>$LOGFILE 2>&1
    ;;
  centos | rhel)
    yum install -y curl >>$LOGFILE 2>&1
    ;;
  *)
    echo "$HELK_INFO_TAG Please install curl for $LSB_DIST $DIST_VERSION.."
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
install_htpasswd() {
  if [ "$SYSTEM_KERNEL" == "Linux" ]; then
    echo "$HELK_INFO_TAG Installing htpasswd.."
    case "$LSB_DIST" in
    ubuntu | debian | raspbian)
      apt install -y apache2-utils >>$LOGFILE 2>&1
      ;;
    centos | rhel)
      yum install -y httpd-tools >>$LOGFILE 2>&1
      ;;
    *)
      echo "$HELK_INFO_TAG Please install htpasswd for $LSB_DIST $DIST_VERSION.."
      exit 1
      ;;
    esac
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
      echoerror "Could not install htpasswd for $LSB_DIST $DIST_VERSION (Error Code: $ERROR)."
      exit 1
    fi
  else
    echo "$HELK_INFO_TAG Please install htpasswd for $SYSTEM_KERNEL.."
  fi
}

# ****** Installing docker via convenience script ***********
install_docker() {
  echo "$HELK_INFO_TAG Installing docker via convenience script.."
  curl -fsSL https://get.docker.com -o get-docker.sh >>$LOGFILE 2>&1
  chmod +x get-docker.sh >>$LOGFILE 2>&1
  ./get-docker.sh >>$LOGFILE 2>&1
  if [ "$LSB_DIST" == "centos" ]; then
    systemctl enable docker.service
    systemctl start docker.service
  fi
  ERROR=$?
  if [ $ERROR -ne 0 ]; then
    echoerror "Could not install docker via convenience script (Error Code: $ERROR)."
    if [ -x "$(command -v snap)" ]; then
      SNAP_VERSION=$(snap version | grep -w 'snap' | awk '{print $2}')
      echo "$HELK_INFO_TAG Snap v$SNAP_VERSION is available. Trying to install docker via snap.."
      snap install docker >>$LOGFILE 2>&1
      ERROR=$?
      if [ $ERROR -ne 0 ]; then
        echoerror "Could not install docker via snap (Error Code: $ERROR)."
        exit 1
      fi
      echo "$HELK_INFO_TAG Docker successfully installed via snap."
    else
      echo "$HELK_INFO_TAG Docker could not be installed. Check $LOGFILE for details."
      exit 1
    fi
  fi
}

# ****** Installing docker compose from github.com/docker/compose ***********
install_docker_compose() {
  echo "$HELK_INFO_TAG Installing docker-compose.."
  COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
  curl -L https://github.com/docker/compose/releases/download/"$COMPOSE_VERSION"/docker-compose-"$(uname -s)"-"$(uname -m)" -o /usr/local/bin/docker-compose >>$LOGFILE 2>&1
  chmod +x /usr/local/bin/docker-compose >>$LOGFILE 2>&1
  if [ "$LSB_DIST" == "centos" ]; then
    # Link docker-compose so can be used with sudo
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
  fi
  ERROR=$?
  if [ $ERROR -ne 0 ]; then
    echoerror "Could not install docker-compose (Error Code: $ERROR)."
    exit 1
  fi
}

# *********** Set helk kibana UI password ******************************
set_kibana_ui_password() {
  if [[ -z "$KIBANA_UI_PASSWORD_INPUT" ]]; then
    echo -e "\n$HELK_INFO_TAG Please make sure to create a custom Kibana password and store it securely for future use."
    sleep 1
    while true; do
      read -t 90 -p "$HELK_INFO_TAG Set HELK Kibana UI Password: " -e -i "hunting" KIBANA_UI_PASSWORD_INPUT
      READ_INPUT=$?
      KIBANA_UI_PASSWORD_INPUT=${KIBANA_UI_PASSWORD_INPUT:-"hunting"}
      if [ $READ_INPUT = 142 ]; then
        echo -e "\n$HELK_INFO_TAG HELK Kibana UI password set to ${KIBANA_UI_PASSWORD_INPUT}"
        break
      else
        read -p "$HELK_INFO_TAG Verify HELK Kibana UI Password: " KIBANA_UI_PASSWORD_INPUT_VERIFIED
        #echo -e "$HELK_INFO_TAG HELK Kibana UI password set to ${KIBANA_UI_PASSWORD_INPUT}"
        # *********** Validating Password Input ***************
        if [[ "$KIBANA_UI_PASSWORD_INPUT" == "$KIBANA_UI_PASSWORD_INPUT_VERIFIED" ]]; then
          break
        else
          echo -e "${RED}Error...${STD}"
          echo "$HELK_INFO_TAG Your password values do not match.."
        fi
      fi
    done
  fi
  if [[ $SUBSCRIPTION_CHOICE == "basic" ]]; then
    # *********** Check if htpasswd is installed ***************
    if ! [ -x "$(command -v htpasswd)" ]; then
      install_htpasswd
    fi
    mv helk-nginx/htpasswd.users helk-nginx/htpasswd.users_backup >>$LOGFILE 2>&1
    htpasswd -b -c helk-nginx/htpasswd.users "helk" "$KIBANA_UI_PASSWORD_INPUT" >>$LOGFILE 2>&1
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
      echoerror "Could not add helk to htpasswd.users file (Error Code: $ERROR)."
      exit 1
    fi
  else
    echo "$HELK_INFO_TAG Subscription Choice MUST be provided first.."
    exit 1
  fi
}

# *********** Set HELK network settings ***************
set_network() {
  if [[ -z "$HOST_IP" ]]; then
    # *********** Getting Host IP ***************
    # https://github.com/Invoke-IR/ACE/blob/master/ACE-Docker/start.sh
    #echo "$HELK_INFO_TAG Obtaining current host IP.."
    case "${SYSTEM_KERNEL}" in
    Linux*) HOST_IP=$(ip route get 1 | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | tail -1) ;;
    Darwin*) HOST_IP=$(ifconfig en0 | grep inet | grep -v inet6 | cut -d ' ' -f2) ;;
            *)          HOST_IP="UNKNOWN:${SYSTEM_KERNEL}"
    esac
    # *********** Accepting Defaults or Allowing user to set the HELK IP ***************
    local ip_choice
    read -t 90 -p "$HELK_INFO_TAG Set HELK IP. Default value is your current IP: " -e -i "${HOST_IP}" ip_choice
    # ******* Validation ************
    READ_INPUT=$?
    HOST_IP="${ip_choice:-$HOST_IP}"
    if [ $READ_INPUT  = 142 ]; then
        echo -e "\n$HELK_INFO_TAG HELK IP set to ${HOST_IP}"
    else
        echo "$HELK_INFO_TAG HELK IP set to ${HOST_IP}"
    fi
  fi
}

# *********** Building and Running HELK Images ***************
build_helk() {
  ## ****** Setting KAFKA ADVERTISED_LISTENER environment variable ***********
  export ADVERTISED_LISTENER=$HOST_IP

  echo "$HELK_INFO_TAG Building & running HELK from $COMPOSE_CONFIG file.."
  docker-compose -f $COMPOSE_CONFIG up --build -d >>$LOGFILE 2>&1
  ERROR=$?
  if [ $ERROR -ne 0 ]; then
    echoerror "Could not run HELK via docker-compose file $COMPOSE_CONFIG (Error Code: $ERROR)."
    exit 1
  fi
}

# *********** Asking user for docker compose config ***************
set_helk_build() {
  if [[ -z "$HELK_BUILD" ]]; then
    while true; do
      echo " "
      echo "*****************************************************"
      echo "*      HELK - Docker Compose Build Choices          *"
      echo "*****************************************************"
      echo " "
      echo "1. KAFKA + KSQL + ELK + NGNIX"
      echo "2. KAFKA + KSQL + ELK + NGNIX + ELASTALERT"
      echo "3. KAFKA + KSQL + ELK + NGNIX + SPARK + JUPYTER"
      echo "4. KAFKA + KSQL + ELK + NGNIX + SPARK + JUPYTER + ELASTALERT"
      echo " "

      local CONFIG_CHOICE
      read -t 30 -p "Enter build choice [ 1 - 4]: " -e -i "1" CONFIG_CHOICE
      READ_INPUT=$?
      HELK_BUILD=${CONFIG_CHOICE:-"helk-kibana-analysis"}
      if [ $READ_INPUT = 142 ]; then
        echo -e "\n$HELK_INFO_TAG HELK build set to ${HELK_BUILD}"
        break
      else
        echo "$HELK_INFO_TAG HELK build set to ${HELK_BUILD}"
        case $CONFIG_CHOICE in
                    1) HELK_BUILD='helk-kibana-analysis';break;;
                    2) HELK_BUILD='helk-kibana-analysis-alert';break;;
        3)
          if [[ $AVAILABLE_MEMORY -le $INSTALL_MINIMUM_MEMORY_NOTEBOOK ]]; then
            echo "$HELK_INFO_TAG Your available memory for HELK build option ${HELK_BUILD} is not enough."
            echo "$HELK_INFO_TAG Minimum required for this build option is $INSTALL_MINIMUM_MEMORY_NOTEBOOK MBs."
            echo "$HELK_INFO_TAG Please Select option 1 or re-run the script after assigning the correct amount of memory"
            sleep 4
          else
            HELK_BUILD='helk-kibana-notebook-analysis'
                        break;
          fi
          ;;
        4)
          if [[ $AVAILABLE_MEMORY -le $INSTALL_MINIMUM_MEMORY_NOTEBOOK ]]; then
            echo "$HELK_INFO_TAG Your available memory for HELK build option ${HELK_BUILD} is not enough."
            echo "$HELK_INFO_TAG Minimum required for this build option is $INSTALL_MINIMUM_MEMORY_NOTEBOOK MBs."
            echo "$HELK_INFO_TAG Please Select option 1 or re-run the script after assigning the correct amount of memory"
            sleep 4
          else
            HELK_BUILD='helk-kibana-notebook-analysis-alert'
                        break;
          fi
          ;;
        *)
          echo -e "${RED}Error...${STD}"
          echo "$HELK_ERROR_TAG Not a valid build"
          ;;
        esac
      fi
    done
  fi
}

# *********** Install and set up pre-requirements ***************
prepare_helk() {
  if [ "$SYSTEM_KERNEL" == "Linux" ]; then
    # *********** Check if curl is installed ***************
    if ! [ -x "$(command -v curl)" ]; then
      install_curl
    fi
    # *********** Check if docker is installed ***************
    if [ -x "$(command -v docker)" ]; then
      echo "$HELK_INFO_TAG Docker already installed"
      # Check to make sure docker is started before continuing with all the components that use docker
      echo "$HELK_INFO_TAG Assesing if Docker is running.."
      while true; do
        if (systemctl --quiet is-active docker.service); then
          echo "$HELK_INFO_TAG Docker is running."
          break
        else
          echo "$HELK_ERROR_TAG Docker is not running. Attempting to start it.."
          systemctl enable docker.service
          systemctl start docker.service
          sleep 2
        fi
      done
      echo "$HELK_INFO_TAG Making sure you assigned enough disk space to the current Docker base directory"
      AVAILABLE_DOCKER_DISK=$(df -m "$(docker info --format '{{.DockerRootDir}}')" | awk '$1 ~ /\//{printf "%.f", $4 / 1024}')
      if [[ "${AVAILABLE_DOCKER_DISK}" -ge $INSTALL_MINIMUM_DISK ]]; then
        echo "$HELK_INFO_TAG Available Docker Disk: ${AVAILABLE_DOCKER_DISK} GBs"
      else
        echo "$HELK_ERROR_TAG YOU DO NOT HAVE ENOUGH DOCKER DISK SPACE ASSIGNED"
        echo "$HELK_ERROR_TAG Available Docker Disk: ${AVAILABLE_DOCKER_DISK} GBs"
        echo -e "$INSTALL_ERROR_CHECK_WIKI"
        exit 1
      fi
    else
      install_docker
    fi
    # ********** Check if docker-compose is installed *******
    if ! [ -x "$(command -v docker-compose)" ] && ! [ -x "$(command -v /usr/local/bin/docker-compose)" ]; then
      install_docker_compose
    fi
  else
    # *********** Check if docker is installed ***************
    if ! [ -x "$(command -v docker)" ] && ! [ -x "$(command -v docker-compose)" ]; then
      echo "$HELK_INFO_TAG Please install Docker & Docker-compose for $SYSTEM_KERNEL"
      exit 1
    fi
  fi

  # *********** Checking internal set up ***************
  echo "$HELK_INFO_TAG Checking local vm.max_map_count variable and setting it to $SYSCTL_VM_MAX_MAP_COUNT"
  if [ -n "$SYSCTL_VM_MAX_MAP_COUNT" -a -f /proc/sys/vm/max_map_count ]; then
    sysctl -q -w vm.max_map_count="$SYSCTL_VM_MAX_MAP_COUNT" >>$LOGFILE 2>&1
    if [ $ERROR -ne 0 ]; then
      echoerror "Could not set vm.max_map_count to $SYSCTL_VM_MAX_MAP_COUNT (Error Code: $ERROR)."
    fi
  fi
  echo "$HELK_INFO_TAG Setting local vm.swappiness variable to $SYSCTL_VM_SWAPPINESS"
  if [ -n "$SYSCTL_VM_SWAPPINESS" -a -f /proc/sys/vm/swappiness ]; then
    sysctl -q -w vm.swappiness=$SYSCTL_VM_SWAPPINESS >>$LOGFILE 2>&1
    if [ $ERROR -ne 0 ]; then
      echoerror "Could not set vm.swappiness to $SYSCTL_VM_SWAPPINESS (Error Code: $ERROR)."
    fi
  fi
    echo "vm.max_map_count = $SYSCTL_VM_MAX_MAP_COUNT" > /etc/sysctl.d/90-helk-overwritten-during-docker-install-sysctl-tuning.conf;
    echo "vm.swappiness = $SYSCTL_VM_SWAPPINESS" >> /etc/sysctl.d/90-helk-overwritten-during-docker-install-sysctl-tuning.conf;
}

get_jupyter_credentials() {
  if [[ ${HELK_BUILD} == "helk-kibana-notebook-analysis" ]] || [[ ${HELK_BUILD} == "helk-kibana-notebook-analysis-alert" ]]; then
    until (docker logs helk-jupyter 2>&1 | grep -q "The Jupyter Notebook is running at"); do sleep 5; done
    jupyter_token="$(docker exec -i helk-jupyter jupyter notebook list | grep "token" | sed 's/.*token=\([^ ]*\).*/\1/')" >>$LOGFILE 2>&1
    echo "HELK JUPYTER CURRENT TOKEN: ${jupyter_token}"
  fi
}

check_logstash_connected() {
  echo "$HELK_INFO_TAG Waiting for some services to be up ....."
  until (docker logs helk-logstash 2>&1 | grep -q "Restored connection to ES instance"); do sleep 5; done
}

show_banner() {
  # *********** Showing HELK Docker menu options ***************
  echo " "
  echo "***********************************************"
  echo "**          HELK - THE HUNTING ELK           **"
  echo "**                                           **"
  echo "** Author: Roberto Rodriguez (@Cyb3rWard0g)  **"
  echo "** HELK build version: ${HELK_BUILD_VERSION} **"
  echo "** HELK ELK version: ${HELK_ELK_VERSION}     **"
  echo "** License: GPL-3.0                          **"
  echo "***********************************************"
  echo " "
}

show_final_information() {
  echo " "
  echo " "
  echo "***********************************************************************************"
  echo "** $HELK_INFO_TAG HELK WAS INSTALLED SUCCESSFULLY                      **"
  echo "** $HELK_INFO_TAG USE THE FOLLOWING SETTINGS TO INTERACT WITH THE HELK **"
  echo "***********************************************************************************"
  echo " "
  if [[ ${HELK_BUILD} == "helk-kibana-notebook-analysis" ]] || [[ ${HELK_BUILD} == "helk-kibana-notebook-analysis-alert" ]]; then
    echo "HELK KIBANA URL: https://${HOST_IP}"
    echo "HELK KIBANA USER: helk"
    echo "HELK KIBANA PASSWORD: ${KIBANA_UI_PASSWORD_INPUT}"
    echo "HELK SPARK MASTER UI: https://${HOST_IP}:8080"
    echo "HELK JUPYTER SERVER URL: https://${HOST_IP}/jupyter"
    get_jupyter_credentials
  elif [[ ${HELK_BUILD} == "helk-kibana-analysis" ]] || [[ ${HELK_BUILD} == "helk-kibana-analysis-alert" ]]; then
    echo "HELK KIBANA URL: https://${HOST_IP}"
    echo "HELK KIBANA USER: helk"
    echo "HELK KIBANA PASSWORD: ${KIBANA_UI_PASSWORD_INPUT}"
  fi
  echo "HELK ZOOKEEPER: ${HOST_IP}:2181"
  echo "HELK KSQL SERVER: ${HOST_IP}:8088"
  echo " "
  echo "IT IS HUNTING SEASON!!!!!"
  echo " "
  echo "You can stop all the HELK docker containers by running the following command:"
  echo " [+] sudo docker-compose -f $COMPOSE_CONFIG stop"
  echo " "
}

setup_firewall(){
    if [[ "$LSB_DIST" == "centos" ]]; then
        source ./helk_setup_firewall.sh
        if [[ $? -ne 0 ]]; then
            echoerror "Could not start firewall script..."
        fi
    fi
}

install_helk() {
  show_banner
  check_min_requirements
  check_system_info
  set_helk_build
  set_network
  set_kibana_ui_password
  prepare_helk
  persist_conf
  set_install_info
  setup_firewall
  build_helk
  check_logstash_connected
  show_final_information
}

usage() {
  echo " "
  echo "Usage: $0 [option...]" >&2
  echo
  echo "   -p         set helk kibana ui password"
  echo "   -i         set HELKs IP address"
  echo "   -b         set HELKs build (helk-kibana-analysis OR helk-kibana-notebook-analysis)"
  echo "   -q         quiet -> not output to the console"
  echo
  echo "Examples:"
  echo " $0                                                                                           Install HELK manually"
  echo " $0 -p As3gur@! -i 192.168.64.131 -b 'helk-kibana-analysis'                                   Install HELK quietly"
  echo " "
  exit 1
}

# ************ Start HELK Install **********************
# ************ Command Options **********************
while getopts p:i:b:l:eq option
do
    case "${option}"
    in
  p) KIBANA_UI_PASSWORD_INPUT=$OPTARG ;;
  i) HOST_IP=$OPTARG ;;
  b) HELK_BUILD=$OPTARG ;;
  e) ELASTICSEARCH_PASSWORD_INPUT=$OPTARG ;;
  q) quiet="TRUE" ;;
  \?) usage ;;
  esac
done

if [ -z "$KIBANA_UI_PASSWORD_INPUT" ] && [ -z "$HOST_IP" ] && [ -z "$HELK_BUILD" ]; then
  install_helk
else
  if [[ "$HOST_IP" =~ ^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$ ]]; then
    for i in 1 2 3 4; do
      if [ "$(echo "$HOST_IP" | cut -d. -f$i)" -gt 255 ]; then
        echo "$HELK_ERROR_TAG $HOST_IP is not a valid IP Address"
        usage
      fi
    done
    # *********** Validating helk build***************
    case $HELK_BUILD in
    helk-kibana-analysis) ;;
    helk-kibana-analysis-alert) ;;
    helk-kibana-notebook-analysis) ;;
    helk-kibana-notebook-analysis-alert) ;;
    *)
      echo "$HELK_ERROR_TAG Not a valid build. Valid Options: kafka, helk-kibana-analysis OR helk-kibana-notebook-analysis "
      usage
      ;;
    esac
    # *********** Quiet or verbose ***************
    if [[ -z "$quiet" ]]; then
      install_helk
    else
      install_helk >>$LOGFILE 2>&1
    fi
  else
    echo "$HELK_ERROR_TAG Make sure you set the right parameters"
    usage
  fi
fi
