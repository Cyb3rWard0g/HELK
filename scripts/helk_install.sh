#!/bin/bash

# HELK Installation Script (Elasticsearch, Logstash, Kibana & Nginx)
# HELK build version: 0.9 (BETA Script)
# Author: Roberto Rodriguez @Cyb3rWard0g

# Description: This script installs every single component of the ELK Stack plus Nginx
# ELK version: 5x
# Blog: https://cyberwardog.blogspot.com/2017/02/setting-up-pentesting-i-mean-threat_98.html

LOGFILE="/var/log/helk-install.log"

echoerror() {
    printf "${RC} * ERROR${EC}: $@\n" 1>&2;
}


echo "[HELK INFO] Installing updates.."
apt-get update >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install updates (Error Code: $ERROR)."
    fi

echo "[HELK INFO] Installing openjdk-8-jre-headless.."
apt-get install -y openjdk-8-jre-headless >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install openjdk-8-jre-headless (Error Code: $ERROR)."
    fi

# Elastic signs all of their packages with their own Elastic PGP signing key.
echo "[HELK INFO] Downloading and installing (writing to a file) the public signing key to the host.."
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add - >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not write the public signing key to the host (Error Code: $ERROR)."
    fi

# Before installing elasticsearch, we have to set the elastic packages definitions to our source list.
# For this step, elastic recommends to have "apt-transport-https" installed already or install it before adding the elasticsearch apt repository source list definition to your /etc/apt/sources.list
echo "[HELK INFO] Installing apt-transport-https.."
apt-get install apt-transport-https >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install apt-transport-https (Error Code: $ERROR)."
    fi

echo "[HELK INFO] Adding elastic packages source list definitions to your sources list.."
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not add elastic packages source list definitions to your source list (Error Code: $ERROR)."
    fi

echo "[HELK INFO] Installing updates.."
apt-get update >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install updates (Error Code: $ERROR)."
    fi

# *********** Installing Elasticsearch ***************
echo "[HELK INFO] Installing Elasticsearch.."
apt-get install elasticsearch >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install elasticsearch (Error Code: $ERROR)."
    fi
    
echo "[HELK INFO] Creating a backup of Elasticsearch's original yml file.."
mv /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/backup_elasticsearch.yml >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not create a backup of the elasticsearch.yml config (Error Code: $ERROR)."
    fi
    
echo "[HELK INFO] copying custom elasticsearch.yml file to /etc/elasticsearch/.."
cp -v ../elasticsearch/elasticsearch.yml /etc/elasticsearch/ >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not copy custom elasticsearch config (Error Code: $ERROR)."
    fi
    
echo "[HELK INFO] Starting elasticsearch and setting elasticsearch to start automatically when the system boots.."
systemctl daemon-reload >> $LOGFILE 2>&1
systemctl enable elasticsearch.service >> $LOGFILE 2>&1
systemctl start elasticsearch.service >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not start elasticsearch and set elasticsearch to start automatically when the system boots (Error Code: $ERROR)."
    fi

echo "[HELK INFO] Installing updates.."
apt-get update >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install updates (Error Code: $ERROR)."
    fi

# *********** Installing Kibana ***************
echo "[HELK INFO] Installing Kibana.."
apt-get install kibana >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install kibana (Error Code: $ERROR)."
    fi
    
echo "[HELK INFO] Creating a backup of Kibana's original yml file.."
mv /etc/kibana/kibana.yml /etc/kibana/backup_kibana.yml >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not create a backup of Kibana's original yml file (Error Code: $ERROR)."
    fi
    
echo "[HELK INFO] copying custom kibana.yml file to /etc/kibana/.."
cp -v ../kibana/kibana.yml /etc/kibana/ >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not copy custom kibana.yml file (Error Code: $ERROR)."
    fi
    
echo "[HELK INFO] Starting kibana and setting kibana to start automatically when the system boots.."
systemctl daemon-reload >> $LOGFILE 2>&1
systemctl enable kibana.service >> $LOGFILE 2>&1
systemctl start kibana.service >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not start kibana and set kibana to start automatically when the system boots (Error Code: $ERROR)."
    fi

# *********** Installing Nginx ***************
echo "[HELK INFO] Installing Nginx.."
apt-get -y install nginx >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install nginx (Error Code: $ERROR)."
    fi
    
echo "[HELK INFO] Adding a htpasswd.users file to nginx.."
cp -v ../nginx/docker/htpasswd.users /etc/nginx/ >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not add a htpasswd.users file to nginx (Error Code: $ERROR)."
    fi
    
echo "[HELK INFO] Creating a backup of Nginx's config file.."
mv /etc/nginx/sites-available/default /etc/nginx/sites-available/backup_default >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not create a backup of nginx config file (Error Code: $ERROR)."
    fi
    
echo "[HELK INFO] copying custom nginx config file to /etc/nginx/sites-available/.."
cp -v ../nginx/default /etc/nginx/sites-available/ >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not copy custom nginx file (Error Code: $ERROR)."
    fi
    
echo "[HELK INFO] testing nginx configuration.."
nginx -t >> $LOGFILE 2>&1

echo "[HELK INFO] Restarting nginx service.."
systemctl restart nginx >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not restart nginx (Error Code: $ERROR)."
    fi

echo "[HELK INFO] Installing updates.."
apt-get update >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install update (Error Code: $ERROR)."
    fi

# *********** Installing Python ***************
echo "[HELK INFO] Installing Python.."
apt-get -y install python >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install python (Error Code: $ERROR)."
    fi

# *********** Installing PIP ***************
echo "[HELK INFO] Installing PIP.."
apt-get -y install python-pip >> $LOGFILE 2>&1
pip install --upgrade pip >> $LOGFILE 2>&1
ERROR=$?
  if [ $ERROR -ne 0 ]; then
        echoerror "Could not install python-pip (Error Code: $ERROR)."
  fi

# *********** Installing AlienVault OTX Python SDK ***************
echo "[HELK INFO] Installing AlienVault OTX Python SDK.."
pip install OTXv2 >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install OTX Python SDK (Error Code: $ERROR)."
    fi

# *********** Installing Pandas ***************
echo "[HELK INFO] Installing Pandas.."
pip install pandas >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install Pandas (Error Code: $ERROR)."
    fi

# *********** Copying Intel files to HELK ***************
echo "[HELK INFO] Copying Intel files to HELK"
mkdir /opt/helk/
mkdir /opt/helk/otx
cp -v ../enrichments/otx/* /opt/helk/otx/ >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not copy intel files to HELK (Error Code: $ERROR)."
    fi
# *********** Creating Cron Job to run OTX script every monday at 8AM and capture last 30 days of Intel *************
echo "[HELK INFO] Creating a cronjob for OTX intel script"
mkdir /opt/helk/scripts
cp -v otx_helk.py /opt/helk/scripts/
cronjob="0 8 * * 1 python /opt/helk/scripts/otx_helk.py"
echo "$cronjob" | crontab - >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not create cronjob for OTX intel script (Error Code: $ERROR)."
    fi

# *********** Installing Logstash ***************
echo "[HELK INFO] Installing Logstash.."
apt-get install logstash >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install logstash (Error Code: $ERROR)."
    fi
 
echo "[HELK INFO] Copying logstash's .conf files.."
cp -av ../logstash/pipeline/* /etc/logstash/conf.d/ >> $LOGFILE 2>&1

ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not copy logstash files (Error Code: $ERROR)."
    fi
    
echo "[HELK INFO] Starting logstash and setting Logstash to start automatically when the system boots.."
systemctl start logstash >> $LOGFILE 2>&1
systemctl restart logstash >> $LOGFILE 2>&1
systemctl enable logstash >> $LOGFILE 2>&1

ERROR=$?
      if [ $ERROR -ne 0 ]; then
        echoerror "Could not start logstash and set it to start automatically when the system boots (Error Code: $ERROR)"
      fi

echo "**********************************************************************************************************"
echo "[HELK INFO] Your HELK has been installed"
echo "[HELK INFO] Browse to your host IP  address from a different computer and enter the following credentials:"
echo "username: helk"
echo "password: hunting"
echo " "
echo "HAPPY HUNTING!!!!!"
echo "**********************************************************************************************************"

