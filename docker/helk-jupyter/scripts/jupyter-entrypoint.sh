#!/bin/bash

# HELK script: jupyter-entrypoint.sh
# HELK script description: Installs postgresql and creates JupyterHub Users
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0
# Reference: https://blog.ouseful.info/2019/02/04/running-a-postgresql-server-in-a-mybinder-container/

HELK_INFO_TAG="[HELK-JUPYTER-DOCKER-INSTALLATION-INFO]"
HELK_ERROR_TAG="[HELK-JUPYTER-DOCKER-INSTALLATION-ERROR]"

# ************ Starting Postgresql for Spark ****************
PGDATA=${PGDATA:-/home/jupyter/srv/pgsql}
 
if [ ! -d "$PGDATA" ]; then
  /usr/lib/postgresql/10/bin/initdb -D "$PGDATA" --auth-host=md5 --encoding=UTF8
fi
echo "$HELK_INFO_TAG The files belonging to this database system will be owned by user jupyter.."
/usr/lib/postgresql/10/bin/pg_ctl -D "$PGDATA" status || /usr/lib/postgresql/10/bin/pg_ctl -D "$PGDATA" -l "$PGDATA/pg.log" start

# ************ Checking if user hive exists ****************
echo "$HELK_INFO_TAG Checking if user hive already exists.."
HIVE_USER_EXISTS=$(psql postgres -tAc "SELECT 1 FROM pg_catalog.pg_user u WHERE u.usename='hive'")
if [[ $HIVE_USER_EXISTS != "1" ]]; then
    echo "$HELK_INFO_TAG postgres user hive does not exist.."
    psql postgres --command "CREATE USER hive;"
    psql postgres --command "ALTER ROLE hive WITH PASSWORD 'sparkpassword';"
    psql postgres --command "CREATE DATABASE hive_metastore;"
    psql postgres --command "GRANT ALL PRIVILEGES ON DATABASE hive_metastore TO hive;"
elif [[ $HIVE_USER_EXISTS == "1" ]]; then
    echo "$HELK_INFO_TAG postgres hive user already exists.."
fi

echo "$HELK_INFO_TAG Starting Jupyter.."
exec "$@"