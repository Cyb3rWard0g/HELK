#!/bin/bash

# HELK script: helk_update.sh
# HELK script description: Update and Rebuild HELK
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# Script Author: Dev Dua (@devdua)
# License: GPL-3.0

HELK_BUILD_VERSION="v0.1.9-alpha03272020"
HELK_ELK_VERSION="7.6.2"

RED='\033[0;31m'
CYAN='\033[0;36m'
WAR='\033[1;33m'
STD='\033[0m'

HELK_INFO_TAG="[HELK-UPDATE-INFO]"
HELK_ERROR_TAG="[HELK-UPDATE-ERROR]"
HELK_WARNING_TAG="[HELK-UPDATE-WARNING]"

if [[ $EUID -ne 0 ]]; then
   echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} YOU MUST BE ROOT TO RUN THIS SCRIPT!!!" 
   exit 1
fi

SYSTEM_KERNEL="$(uname -s)"

show_banner(){
    # *********** Showing HELK Docker menu options ***************
    echo " "
    echo "***********************************************"
    echo "**          HELK - THE HUNTING ELK           **"
    echo "**                                           **"
    echo "** Author: Roberto Rodriguez (@Cyb3rWard0g)  **"
    echo "** HELK build version: ${HELK_BUILD_VERSION} **"
    echo "** HELK ELK version: {$HELK_ELK_VERSION}     **"
    echo "** License: GPL-3.0                          **"
    echo "***********************************************"
    echo " "
}

# *********** Building and Running HELK Images ***************
build_helk(){
    COMPOSE_CONFIG="${HELK_BUILD}-${SUBSCRIPTION_CHOICE}.yml"
    ## ****** Setting KAFKA ADVERTISED_LISTENER environment variable ***********
    export ADVERTISED_LISTENER=$HOST_IP

    echo "$HELK_INFO_TAG Building & running HELK from $COMPOSE_CONFIG file.."
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
            read -t 30 -p ">> Set HELK elastic subscription (basic or trial): " -e -i "basic" subscription_input
            READ_INPUT=$?
            SUBSCRIPTION_CHOICE=${subscription_input:-"basic"}
            if [ $READ_INPUT = 142 ]; then
                echo -e "\n${CYAN}[HELK-UPDATE-INFO]${STD} HELK elastic subscription set to ${SUBSCRIPTION_CHOICE}"
                break
            else
                echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} HELK elastic subscription set to ${SUBSCRIPTION_CHOICE}"
                # *********** Validating subscription Input ***************
                case $SUBSCRIPTION_CHOICE in
                    basic) break;;
                    trial) break;;
                    *)
                        echo -e "${RED}[HELK-UPDATE-ERROR]${STD} Not a valid subscription. Valid Options: basic or trial"
                    ;;
                esac
            fi
        done
    fi
}

# *********** Set helk elasticsearch password ******************************
set_elasticsearch_password(){
    if [[ -z "$ELASTICSEARCH_PASSWORD_INPUT" ]] && [[ $SUBSCRIPTION_CHOICE == "trial" ]]; then
        echo -e "\nIf you used a custom Elasticsearch password then you must use fill it in here, otherwise use the filled in default."
        sleep 2
        while true; do
            read -t 180 -p "$HELK_INFO_TAG Set HELK Elasticsearch Password: " -e -i "elasticpassword" ELASTICSEARCH_PASSWORD_INPUT
            READ_INPUT=$?
            ELASTICSEARCH_PASSWORD_INPUT=${ELASTICSEARCH_PASSWORD_INPUT:-"elasticpassword"}
            if [ $READ_INPUT = 142 ]; then
                echo -e "\n$HELK_INFO_TAG HELK elasticsearch password set to ${ELASTICSEARCH_PASSWORD_INPUT}"
                break
            else
                read -p "$HELK_INFO_TAG Verify HELK Elasticsearch Password: " ELASTICSEARCH_PASSWORD_INPUT_VERIFIED
                echo -e "$HELK_INFO_TAG HELK elasticsearch password set to ${ELASTICSEARCH_PASSWORD_INPUT}"
                # *********** Validating Password Input ***************
                if [[ "$ELASTICSEARCH_PASSWORD_INPUT" == "$ELASTICSEARCH_PASSWORD_INPUT_VERIFIED" ]]; then
                    break
                else
                    echo -e "${RED}Error...${STD}"
                    echo "$HELK_INFO_TAG Your password values do not match.."
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
        echo "If you used a custom Kibana password then you must use fill it in here, otherwise use the filled in default."
        sleep 2
        while true; do
            read -t 180 -p "$HELK_INFO_TAG Set HELK Kibana UI Password: " -e -i "hunting" KIBANA_UI_PASSWORD_INPUT
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
        echo "$HELK_INFO_TAG Subscription Choice MUST be provided first.."
        exit 1
    fi
}
# *********** Set HELK network settings ***************
set_network(){
    if [[ -z "$HOST_IP" ]]; then
        # *********** Getting Host IP ***************
        # https://github.com/Invoke-IR/ACE/blob/master/ACE-Docker/start.sh
        #echo "$HELK_INFO_TAG Obtaining current host IP.."
        case "${SYSTEM_KERNEL}" in
            Linux*)     HOST_IP=$(ip route get 1 | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | tail -1);;
            Darwin*)    HOST_IP=$(ifconfig en0 | grep inet | grep -v inet6 | cut -d ' ' -f2);;
            *)          HOST_IP="UNKNOWN:${SYSTEM_KERNEL}"
        esac
        # *********** Accepting Defaults or Allowing user to set the HELK IP ***************
        local ip_choice
        read -t 180 -p "$HELK_INFO_TAG Set HELK IP. Default value is your current IP: " -e -i ${HOST_IP} ip_choice
        # ******* Validation ************
        #READ_INPUT=$?
        #HOST_IP="${ip_choice:-$HOST_IP}"
        #if [ $READ_INPUT  = 142 ]; then
        #    echo -e "\n$HELK_INFO_TAG HELK IP set to ${HOST_IP}"
        #else
        #    echo "$HELK_INFO_TAG HELK IP set to ${HOST_IP}"
        #fi
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

check_min_requirements(){
    systemKernel="$(uname -s)"
    echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} HELK being hosted on a $systemKernel box"
    if [ "$systemKernel" == "Linux" ]; then 
        AVAILABLE_MEMORY=$(awk '/MemAvailable/{printf "%.f", $2/1024/1024}' /proc/meminfo)
        if [ "${AVAILABLE_MEMORY}" -ge "11" ] ; then
            echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} Available Memory (GB): ${AVAILABLE_MEMORY}"
        else
            echo -e "${RED}[HELK-UPDATE-ERROR]${STD} YOU DO NOT HAVE ENOUGH AVAILABLE MEMORY"
            echo -e "${RED}[HELK-UPDATE-ERROR]${STD} Available Memory (GB): ${AVAILABLE_MEMORY}"
            echo -e "${RED}[HELK-UPDATE-ERROR]${STD} Check the requirements section in our UPDATE Wiki"
            echo -e "${RED}[HELK-UPDATE-ERROR]${STD} UPDATE Wiki: https://github.com/Cyb3rWard0g/HELK/wiki/UPDATE"
            exit 1
        fi
    else
        echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} Error retrieving memory info for $systemKernel. Make sure you have at least 11GB of available memory!"
    fi

    # CHECK DOCKER DIRECTORY SPACE
    echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} Making sure you assigned enough disk space to the current Docker base directory"
    AVAILABLE_DOCKER_DISK=$(df -m $(docker info --format '{{.DockerRootDir}}') | awk '$1 ~ /\//{printf "%.f\t\t", $4 / 1024}')    
    if [ "${AVAILABLE_DOCKER_DISK}" -ge "25" ]; then
        echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} Available Docker Disk: $AVAILABLE_DOCKER_DISK"
    else
        echo -e "${RED}[HELK-UPDATE-ERROR]${STD} YOU DO NOT HAVE ENOUGH DOCKER DISK SPACE ASSIGNED"
        echo -e "${RED}[HELK-UPDATE-ERROR]${STD} Available Docker Disk: $AVAILABLE_DOCKER_DISK"
        echo -e "${RED}[HELK-UPDATE-ERROR]${STD} Check the requirements section in our UPDATE Wiki"
        echo -e "${RED}[HELK-UPDATE-ERROR]${STD} UPDATE Wiki: https://github.com/Cyb3rWard0g/HELK/wiki/UPDATE"
        exit 1
    fi
}

check_git_status(){
    GIT_STATUS=$(git status 2>&1)
    RETURN_CODE=$?
    echo -e "Git status: $GIT_STATUS, RetVal : $RETURN_CODE" >> $LOGFILE
    if [[ -z $GIT_STATUS && $RETURN_CODE -gt 0 ]]; then 
        echo -e "${WAR}${HELK_WARNING_TAG}${STD} Git repository corrupted."
        read -p ">> To fix this, all your local modifications to HELK will be overwritten. Do you wish to continue? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            GIT_REPO_CLEAN=0
            echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} HELK will now be refreshed. Re-initializing .git..."
            cd ..
            git init >> $LOGFILE
            cd docker
            echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} Git repository fixed. Fetching latest version of HELK..."
        else
            exit
        fi
    else
        echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} Sanity check passed."   
    fi
}

check_github(){

    if [ -x "$(command -v git)" ]; then
        echo -e "Git is available" >> $LOGFILE
    else
        echo "Git is not available" >> $LOGFILE
        apt-get -qq update >> $LOGFILE 2>&1 && apt-get -qqy install git-core >> $LOGFILE 2>&1
        ERROR=$?
        if [ $ERROR -ne 0 ]; then
            echo -e "${RED}[!]${STD} Could not install Git (Error Code: $ERROR). Check $LOGFILE for details."
            exit 1
        fi
        echo "Git successfully installed." >> $LOGFILE
    fi

    echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} Sanity check..."   
    check_git_status

    if [ $GIT_REPO_CLEAN == 1 ]; then
        if [[ -z "$(git remote | grep helk-repo)" ]]; then
            git remote add helk-repo https://github.com/Cyb3rWard0g/HELK.git  >> $LOGFILE 2>&1
        else
            echo "HELK repo exists" >> $LOGFILE 2>&1
        fi
        
        git remote update >> $LOGFILE 2>&1
        COMMIT_DIFF=$(git rev-list --count master...helk-repo/master 2>&1)
        CURRENT_COMMIT=$(git rev-parse HEAD 2>&1)
        REMOTE_LATEST_COMMIT=$(git rev-parse helk-repo/master 2>&1)
        echo "[CD:$COMMIT_DIFF] HEAD commits --> Current: $CURRENT_COMMIT | Remote: $REMOTE_LATEST_COMMIT" >> $LOGFILE 2>&1
        
        if  [[ ! "$COMMIT_DIFF" == "0" || ! "$CURRENT_COMMIT" == "$REMOTE_LATEST_COMMIT" ]]; then
            echo "Possibly new release available. Commit diff --> $COMMIT_DIFF" >> $LOGFILE 2>&1
            IS_MASTER_BEHIND=$(git branch -v | grep master | grep behind)

            # IF HELK HAS BEEN CLONED FROM OFFICIAL REPO
            if [[ ! "$CURRENT_COMMIT" == "$REMOTE_LATEST_COMMIT" ]]; then
                echo "Difference in HEAD commits --> Current: $CURRENT_COMMIT | Remote: $REMOTE_LATEST_COMMIT" >> $LOGFILE 2>&1   
                echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} New release(s) available. Attempting to pull new code."
                git checkout master >> $LOGFILE 2>&1
                git clean  -d  -fx . >> $LOGFILE 2>&1
                git pull helk-repo master >> $LOGFILE 2>&1
                REBUILD_NEEDED=1
                touch "$UPDATES_FETCHED_FILE"
                echo $REBUILD_NEEDED > "$UPDATES_FETCHED_FILE"
              fi

            # IF HELK HAS BEEN CLONED FROM THE OFFICIAL REPO & MODIFIED
            if [[ -n $IS_MASTER_BEHIND ]]; then
                echo "Current master branch ahead of remote branch, possibly modified. Exiting..." >> $LOGFILE 2>&1
                echo -e "${WAR}${HELK_WARNING_TAG}${STD} Current install has been modified."
                echo -e "${WAR}${HELK_WARNING_TAG}${STD} Please commit your changes using git and then re-run this script."
                exit 1             
            fi
            if [[ $REBUILD_NEEDED == 0 ]] && [[ -z $IS_MASTER_BEHIND ]]; then
                echo "Repository misconfigured. Exiting..." >> $LOGFILE 2>&1
                echo -e "${RED}${HELK_ERROR_TAG}${STD} Current repo is misconfigured."
                echo -e "\nExiting script..."
                exit 1
            fi

        else
            echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} No updates available."    
        fi
    else
        cd ..
        git clean  -d  -fx . >> $LOGFILE 2>&1
        git remote add helk-repo https://github.com/Cyb3rWard0g/HELK.git  >> $LOGFILE 2>&1
        git pull helk-repo master >> $LOGFILE 2>&1    
    fi
}

check_logstash_connected(){
    until (docker logs helk-logstash 2>&1 | grep -q "Restored connection to ES instance" ); do sleep 5; done
}

update_helk() {
    # Give user option to continue with rebuild after repo has been updated
    echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} Git repository updated..."
    read -p "Do you wish to continue and build the docker containers? (y/n) " -n 1 -r
    echo
    if ! [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "\nExiting script..."
        echo "User Exiting..." >> $LOGFILE 2>&1
        exit 1
    fi

    set_helk_build
    set_helk_subscription

    set_network
    set_kibana_ui_password
    set_elasticsearch_password

    echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} Stopping HELK and starting update"
    COMPOSE_CONFIG="${HELK_BUILD}-${SUBSCRIPTION_CHOICE}.yml"
    ## ****** Setting KAFKA ADVERTISED_LISTENER environment variable ***********
    export ADVERTISED_LISTENER=$HOST_IP

    echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} Building & running HELK from $COMPOSE_CONFIG file.."
    docker-compose -f $COMPOSE_CONFIG down >> $LOGFILE 2>&1
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echo -e "${RED}[!]${STD} Could not stop HELK via docker-compose (Error Code: $ERROR). You're possibly running a different HELK license than chosen - $license_choice"
        exit 1
    fi

    #check_min_requirements

    echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} Rebuilding HELK via docker-compose"
    docker-compose -f $COMPOSE_CONFIG up --build -d -V --force-recreate --always-recreate-deps >> $LOGFILE 2>&1
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echo -e "${RED}[!]${STD} Could not run HELK via docker-compose (Error Code: $ERROR). Check $LOGFILE for details."
        exit 1
    fi
    
    secs=$((3 * 60))
    while [ $secs -gt 0 ]; do
        echo -ne "\033[0K\r${CYAN}[HELK-UPDATE-INFO]${STD} Rebuild succeeded, waiting $secs seconds for services to start..."
        sleep 1
        : $((secs--))
    done
    check_logstash_connected
    echo -e "\n${CYAN}[HELK-UPDATE-INFO]${STD} YOUR HELK HAS BEEN UPDATED!"
    echo 0 > "$UPDATES_FETCHED_FILE"
    exit 1
}

LOGFILE="/var/log/helk-update.log"
UPDATES_FETCHED_FILE="/tmp/helk-update"
REBUILD_NEEDED=0
GIT_REPO_CLEAN=1

echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} You can track the verbose output of this script at $LOGFILE\n"
sleep 1

if [[ -e $UPDATES_FETCHED_FILE ]]; then
    UPDATES_FETCHED=`cat $UPDATES_FETCHED_FILE`

    if [ "$UPDATES_FETCHED" == "1" ]; then
      echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} Updates for the HELK repository have already been downloaded..."
      # Give user option to clear the feteched updates
      read -p "Do you to want to use the already downloaded updates? (y/n): " -e -i "n" -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
          echo "Updates already downloaded. Starting update..." >> $LOGFILE 2>&1
          update_helk
      else
        echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} Re-downloading updates..."
        echo "Performing download/update fetch again" >> $LOGFILE 2>&1
        rm $UPDATES_FETCHED_FILE
      fi

    fi
fi

echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} Checking GitHub for updates..."   
check_github

if [ $REBUILD_NEEDED == 1 ]; then
    update_helk
elif [ $GIT_REPO_CLEAN == 0 ]; then
    echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} HELK repository refreshed, please terminate this shell & run the update script again."
    exit 1
else
    echo -e "${CYAN}[HELK-UPDATE-INFO]${STD} YOUR HELK IS ALREADY UP-TO-DATE."
    exit 1
fi