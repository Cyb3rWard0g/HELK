#!/bin/bash

# Notebooks Forge script: jupyter-entrypoint.sh
# Notebooks Forge script description: Installs postgresql
# Notebooks Forge build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0
# Reference: https://blog.ouseful.info/2019/02/04/running-a-postgresql-server-in-a-mybinder-container/

NOTEBOOK_INFO_TAG="[NOTEBOOK-JUPYTER-DOCKER-INSTALLATION-INFO]"
NOTEBOOK_ERROR_TAG="[NOTEBOOK-JUPYTER-DOCKER-INSTALLATION-ERROR]"

# ************ Starting Postgresql for Spark ****************
PGDATA=${PGDATA:-/home/jupyter/srv/pgsql}
 
if [ ! -d "$PGDATA" ]; then
  /usr/lib/postgresql/10/bin/initdb -D "$PGDATA" --auth-host=md5 --encoding=UTF8
fi
echo "$NOTEBOOK_INFO_TAG The files in this database system will be owned by user jupyter.."
/usr/lib/postgresql/10/bin/pg_ctl -D "$PGDATA" status || /usr/lib/postgresql/10/bin/pg_ctl -D "$PGDATA" -l "$PGDATA/pg.log" start

# ************ Checking if user hive exists ****************
echo "$NOTEBOOK_INFO_TAG Checking if user hive already exists.."
HIVE_USER_EXISTS=$(psql postgres -tAc "SELECT 1 FROM pg_catalog.pg_user u WHERE u.usename='hive'")
if [[ $HIVE_USER_EXISTS != "1" ]]; then
    echo "$NOTEBOOK_INFO_TAG postgres user hive does not exist.."
    psql postgres --command "CREATE USER hive;"
    psql postgres --command "ALTER ROLE hive WITH PASSWORD 'sparkpassword';"
    psql postgres --command "CREATE DATABASE hive_metastore;"
    psql postgres --command "GRANT ALL PRIVILEGES ON DATABASE hive_metastore TO hive;"
elif [[ $HIVE_USER_EXISTS == "1" ]]; then
    echo "$NOTEBOOK_INFO_TAG postgres hive user already exists.."
fi

echo "$NOTEBOOK_INFO_TAG Starting Jupyter.."
exec "$@"