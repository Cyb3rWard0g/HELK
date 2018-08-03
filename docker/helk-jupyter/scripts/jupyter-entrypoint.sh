#!/bin/bash

# HELK script: jupyter-entryppoint.sh
# HELK script description: Creates JupyterHub Users
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# ************* Creating JupyterHub Users ***************
declare -a users_index=("hunter1" "hunter2" "hunter3")

JUPYTERHUB_GID=711
JUPYTERHUB_UID=711
JUPYTERHUB_HOME=/opt/helk/jupyterhub
JUPYTER_HOME=/opt/helk/jupyter

echo "[HELK-JUPYTER-DOCKER-INSTALLATION-INFO] Creating JupyterHub Group..."
groupadd -g ${JUPYTERHUB_GID} jupyterhub

for u in ${users_index[@]}; do 
  echo "[HELK-JUPYTER-DOCKER-INSTALLATION-INFO] Creating JupyterHub user ${u} .."
  student_password="${u}P@ssw0rd!"
  echo $student_password >> /opt/helk/user_credentials.txt
  
  JUPYTERHUB_USER_DIRECTORY=${JUPYTERHUB_HOME}/${u}
  mkdir -v $JUPYTERHUB_USER_DIRECTORY

  useradd -p $(openssl passwd -1 ${student_password}) -u ${JUPYTERHUB_UID} -g ${JUPYTERHUB_GID} -d $JUPYTERHUB_USER_DIRECTORY --no-create-home -s /bin/bash ${u}
  
  echo "[HELK-JUPYTER-DOCKER-INSTALLATION-INFO] copying notebooks to ${JUPYTERHUB_USER_DIRECTORY} notebooks directory ..."
  cp -R ${JUPYTER_HOME}/notebooks ${JUPYTERHUB_USER_DIRECTORY}/notebooks
  chown -R ${u}:jupyterhub $JUPYTERHUB_USER_DIRECTORY
  chmod 700 -R $JUPYTERHUB_USER_DIRECTORY

  ((JUPYTERHUB_UID=$JUPYTERHUB_UID + 1))
done

chmod 777 -R /var/log/spark
chmod 777 -R /opt/helk/spark

exec "$@"
