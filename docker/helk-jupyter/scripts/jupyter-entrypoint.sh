#!/bin/bash

# HELK script: jupyter-entryppoint.sh
# HELK script description: Installs postgresql and creates JupyterHub Users
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

echo "[HELK-JUPYTER-DOCKER-INSTALLATION-INFO] Starting postgresql."
service postgresql start

# ************ Checking if user hive exists ****************
HIVE_USER_EXISTS=$(sudo -u postgres psql -tAc "SELECT 1 FROM pg_catalog.pg_user u WHERE u.usename='hive'")
if [[ $HIVE_USER_EXISTS != "1" ]]; then
    echo "[HELK-JUPYTER-DOCKER-INSTALLATION-INFO] Creating Postgres user and hive_metastore.."
    sudo -u postgres psql <<MYQUERY
    CREATE USER hive;
    ALTER ROLE hive WITH PASSWORD 'sparkpassword';
    CREATE DATABASE hive_metastore;
    GRANT ALL PRIVILEGES ON DATABASE hive_metastore TO hive;
MYQUERY
    echo "[HELK-JUPYTER-DOCKER-INSTALLATION-INFO] restarting postgresql."
    service postgresql restart
elif [[ $HIVE_USER_EXISTS == "1" ]]; then
    echo "[HELK-JUPYTER-DOCKER-INSTALLATION-INFO] postgres hive user already exists.."
fi

# ************ Checking if user helk exists ****************
HELK_USER_EXISTS=$(id -u helk > /dev/null 2>&1; echo $?)
if [[ $HELK_USER_EXISTS == "1" ]]; then
    JUPYTERHUB_GID=711
    JUPYTERHUB_UID=711
    JUPYTERHUB_HOME=/opt/helk/jupyterhub
    JUPYTER_HOME=/opt/helk/jupyter
    JUPYTER_NOTEBOOKS=${JUPYTER_HOME}/notebooks

    echo "[HELK-JUPYTER-DOCKER-INSTALLATION-INFO] Creating JupyterHub Group..."
    groupadd -g ${JUPYTERHUB_GID} jupyterhub

    # ************* Create notebooks folder if it is not provided in compose file ******************
    mkdir -p ${JUPYTER_NOTEBOOKS}

    # ************* Creating JupyterHub Admin ***************
    if [[ -z "$JUPYTER_HELK_PWD" ]]; then
        JUPYTER_HELK_PWD='hunting'
    fi

    JUPYTER_ADMIN='helk'
    JUPYTER_ADMIN_DIRECTORY=/home/${JUPYTER_ADMIN}
    echo "JUPYTER_CREDENTIALS:$JUPYTER_ADMIN:$JUPYTER_HELK_PWD" >> /opt/helk/user_credentials.txt
    mkdir -v $JUPYTER_ADMIN_DIRECTORY

    useradd -p $(openssl passwd -1 ${JUPYTER_HELK_PWD}) -u ${JUPYTERHUB_UID} -g ${JUPYTERHUB_GID} -d $JUPYTER_ADMIN_DIRECTORY -s /bin/bash ${JUPYTER_ADMIN}

    cp -R ${JUPYTER_NOTEBOOKS} ${JUPYTER_ADMIN_DIRECTORY}/notebooks
    chown -R ${JUPYTER_ADMIN}:jupyterhub $JUPYTER_ADMIN_DIRECTORY
    chmod 770 -R $JUPYTER_ADMIN_DIRECTORY

    ((JUPYTERHUB_UID=$JUPYTERHUB_UID + 1))

    # ************* Creating JupyterHub Users ***************
    if [[ -z "$JUPYTER_USERS" ]]; then
        JUPYTER_USERS=hunter1
    fi

    IFS=', ' read -r -a users_index <<< "$JUPYTER_USERS"

    for u in ${users_index[@]}; do 
        echo "[HELK-JUPYTER-DOCKER-INSTALLATION-INFO] Creating JupyterHub user ${u} .."
        student_password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
        echo "JUPYTER_CREDENTIALS:${u}:$student_password" >> /opt/helk/user_credentials.txt
        
        JUPYTERHUB_USER_DIRECTORY=/home/${u}
        mkdir -v ${JUPYTERHUB_USER_DIRECTORY}

        useradd -p $(openssl passwd -1 ${student_password}) -u ${JUPYTERHUB_UID} -g ${JUPYTERHUB_GID} -d $JUPYTERHUB_USER_DIRECTORY -s /bin/bash ${u}
        
        echo "[HELK-JUPYTER-DOCKER-INSTALLATION-INFO] copying notebooks to ${JUPYTERHUB_USER_DIRECTORY} notebooks directory ..."
        cp -R ${JUPYTER_NOTEBOOKS} ${JUPYTERHUB_USER_DIRECTORY}/notebooks
        chown -R ${u}:jupyterhub $JUPYTERHUB_USER_DIRECTORY
        chmod 770 -R $JUPYTERHUB_USER_DIRECTORY

        ((JUPYTERHUB_UID=$JUPYTERHUB_UID + 1))
    done

    chmod 777 -R /var/log/spark
    chmod 777 -R /opt/helk/spark
elif [[ $HELK_USER_EXISTS == "0" ]]; then
    echo "[HELK-JUPYTER-DOCKER-INSTALLATION-INFO] Admin helk user already exists.."
fi
echo "[HELK-JUPYTER-DOCKER-INSTALLATION-INFO] Starting Jupyter.."
exec "$@"
