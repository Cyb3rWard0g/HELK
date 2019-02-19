#!/bin/bash

# HELK script: helk_docker_install.sh
# HELK script description: Install docker and docker-compose
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# *********** Check if user is root ***************
if [[ $EUID -ne 0 ]]; then
   echo "[HELK-DOCKER-INSTALLATION-INFO] YOU MUST BE ROOT TO RUN THIS SCRIPT!!!"
   exit 1
fi

# *********** Set Log File ***************
LOGFILE="/var/log/helk-install.log"
echoerror() {
    printf "${RC} * ERROR${EC}: $@\n" 1>&2;
}

# ********* Globals **********************
SYSTEM_KERNEL="$(uname -s)"

echo "[HELK-DOCKER-INSTALLATION-INFO] Checking distribution list and product version"
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
    echo "[HELK-DOCKER-INSTALLATION-INFO] You're using $LSB_DIST version $DIST_VERSION"
elif [ "$SYSTEM_KERNEL" == "Darwin" ]; then
    PRODUCT_NAME="$(sw_vers -productName)"
    PRODUCT_VERSION="$(sw_vers -productVersion)"
    BUILD_VERSION="$(sw_vers -buildVersion)"
    echo "[HELK-DOCKER-INSTALLATION-INFO] You're using $PRODUCT_NAME version $PRODUCT_VERSION"
else
    echo "[HELK-DOCKER-INSTALLATION-INFO] We cannot figure out the SYSTEM_KERNEL, distribution or version of the OS"
fi


# ********** Install Curl ********************
install_curl(){
    echo "[HELK-DOCKER-INSTALLATION-INFO] Installing curl before installing docker.."
    case "$LSB_DIST" in
        ubuntu|debian|raspbian)
            apt-get install -y curl >> $LOGFILE 2>&1
        ;;
        centos|rhel)
            yum install curl >> $LOGFILE 2>&1
        ;;
        *)
            echo "[HELK-DOCKER-INSTALLATION-INFO] Please install curl for $LSB_DIST $DIST_VERSION .."
            exit 1
        ;;
    esac
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install curl for $lsb_dist $dist_version (Error Code: $ERROR)."
        exit 1
    fi
}

# ****** Installing docker via convenience script ***********
install_docker(){
    echo "[HELK-DOCKER-INSTALLATION-INFO] Installing docker via convenience script.."
    curl -fsSL get.docker.com -o get-docker.sh >> $LOGFILE 2>&1
    chmod +x get-docker.sh >> $LOGFILE 2>&1
    ./get-docker.sh >> $LOGFILE 2>&1
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install docker via convenience script (Error Code: $ERROR)."
        if [ -x "$(command -v snap)" ]; then
            SNAP_VERSION=$(snap version | grep -w 'snap' | awk '{print $2}')
            echo "[HELK-DOCKER-INSTALLATION-INFO] Snap v$SNAP_VERSION is available. Trying to install docker via snap.."
            snap install docker >> $LOGFILE 2>&1
            ERROR=$?
            if [ $ERROR -ne 0 ]; then
                echoerror "Could not install docker via snap (Error Code: $ERROR)."
                exit 1
            fi
            echo "[HELK-DOCKER-INSTALLATION-INFO] Docker successfully installed via snap."
        else
            echo "[HELK-DOCKER-INSTALLATION-INFO] Docker could not be installed. Check /var/log/helk-install.log for details."
            exit 1
        fi
    fi
}

# ****** Installing docker compose from github.com/docker/compose ***********
install_docker_compose(){
    echo "[HELK-DOCKER-INSTALLATION-INFO] Installing docker-compose.."
    curl -L https://github.com/docker/compose/releases/download/1.23.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose >> $LOGFILE 2>&1
    chmod +x /usr/local/bin/docker-compose >> $LOGFILE 2>&1
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install docker-compose (Error Code: $ERROR)."
        exit 1
    fi
}

# *********** Main steps *********************
if [ "$SYSTEM_KERNEL" == "Linux" ]; then
    # *********** Check if curl is installed ***************
    if [ -x "$(command -v curl)" ]; then
        echo "[HELK-DOCKER-INSTALLATION-INFO] curl is already installed"
    else
        echo "[HELK-DOCKER-INSTALLATION-INFO] curl is not installed"
        install_curl
    fi

    # *********** Check if docker is installed ***************
    if [ -x "$(command -v docker)" ]; then
        echo "[HELK-DOCKER-INSTALLATION-INFO] Docker already installed"
    else
        echo "[HELK-DOCKER-INSTALLATION-INFO] Docker is not installed"
        install_docker
    fi
    # ********** Check if docker-compose is installed *******
    if [ -x "$(command -v docker-compose)" ]; then
        echo "[HELK-DOCKER-INSTALLATION-INFO] Docker-compose already installed"
    else
        echo "[HELK-DOCKER-INSTALLATION-INFO] Docker-compose is not installed"
        install_docker_compose
    fi
else
    # *********** Check if docker is installed ***************
    if [ -x "$(command -v docker)" ] && [ -x "$(command -v docker-compose)" ]; then
        echo "[HELK-DOCKER-INSTALLATION-INFO] Docker & Docker-compose already installed"
    else
        echo "[HELK-DOCKER-INSTALLATION-INFO] Please innstall Docker & Docker-compose for $SYSTEM_KERNEL"
        exit 1
    fi
fi