#!/bin/bash

# HELK script: helk_install.sh
# HELK script description: Install all the needed components of the HELK
# HELK build version: 0.9 (BETA)
# HELK ELK version: 6.x
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

# References: 
# https://cyberwardog.blogspot.com/2017/02/setting-up-pentesting-i-mean-threat_98.html

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
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list >> $LOGFILE 2>&1
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
cp -v ../nginx/htpasswd.users /etc/nginx/ >> $LOGFILE 2>&1
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
mkdir /opt/helk/scripts >> $LOGFILE 2>&1
cp -v helk_otx.py /opt/helk/scripts/ >> $LOGFILE 2>&1
cronjob="0 8 * * 1 python /opt/helk/scripts/helk_otx.py"
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

echo "[HELK INFO] Creating templates directory and copying custom templates over.."
mkdir /opt/helk/output_templates >> $LOGFILE 2>&1
cp -v ../logstash/output_templates/* /opt/helk/output_templates/ >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not create templates directory and copy custom templates over (Error Code: $ERROR)."
    fi
 
echo "[HELK INFO] Copying logstash's .conf files.."
cp -av ../logstash/pipeline/* /etc/logstash/conf.d/ >> $LOGFILE 2>&1

ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not copy logstash files (Error Code: $ERROR)."
    fi
    
echo "[HELK INFO] Starting logstash and setting Logstash to start automatically when the system boots.."
systemctl enable logstash >> $LOGFILE 2>&1
systemctl start logstash >> $LOGFILE 2>&1
ERROR=$?
      if [ $ERROR -ne 0 ]; then
        echoerror "Could not start logstash and set it to start automatically when the system boots (Error Code: $ERROR)"
      fi

# *********** Creating Kibana Index-patterns, Dashboards and Visualization ***************
echo "[HELK INFO] Creating Kibana index-patterns, dashboards and visualizations automatically.."
mkdir /opt/helk/dashbords>> $LOGFILE 2>&1
cp -v ../kibana/dashboards/* /opt/helk/dashboards/ >> $LOGFILE 2>&1
./helk_kibana_setup.sh >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not create kibana index-patterns, dashboards or visualizations (Error Code: $ERROR)."
    fi

# *********** Install unzip ***************
echo "[HELK INFO] Installing unzip.."
apt-get install unzip >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install unzip (Error Code: $ERROR)."
    fi

# *********** Install ES-Hadoop ***************
echo "[HELK INFO] Installing ES-Hadoop Connector.."
mkdir /opt/helk/es-hadoop >> $LOGFILE 2>&1
wget http://download.elastic.co/hadoop/elasticsearch-hadoop-6.1.1.zip -P /opt/helk/es-hadoop/ >> $LOGFILE 2>&1
unzip /opt/helk/es-hadoop/*.zip -d /opt/helk/es-hadoop/ >> $LOGFILE 2>&1
rm /opt/helk/es-hadoop/*.zip >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install ES-Hadoop (Error Code: $ERROR)."
    fi

# *********** Install ipython & ipython-notebook***************
echo "[HELK INFO] Installing ipython & ipython-notebook.."
apt-get -y install ipython ipython-notebook >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install iPython & iPython-notebook (Error Code: $ERROR)."
    fi

# *********** Install Jupyter***************
echo "[HELK INFO] Installing Jupyter.."
pip install jupyter >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install jupyter (Error Code: $ERROR)."
    fi

# *********** Install Spark ***************
echo "[HELK INFO] Installing Spark.."
mkdir /opt/helk/spark >> $LOGFILE 2>&1
sudo wget -qO- http://mirrors.gigenet.com/apache/spark/spark-2.2.1/spark-2.2.1-bin-hadoop2.7.tgz | sudo tar xvz -C /opt/helk/spark/ >> $LOGFILE 2>&1
cp -f ../enrichments/spark/.bashrc ~/.bashrc >> $LOGFILE 2>&1
cp -v ../enrichments/spark/log4j.properties /opt/helk/spark/spark-2.2.1-bin-hadoop2.7/conf/ >> $LOGFILE 2>&1
cp -v ../enrichments/spark/spark-defaults.conf /opt/helk/spark/spark-2.2.1-bin-hadoop2.7/conf/ >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install spark (Error Code: $ERROR)."
    fi

# Adding SPARK location
export SPARK_HOME=/opt/helk/spark/spark-2.2.1-bin-hadoop2.7
export PATH=$SPARK_HOME/bin:$PATH

# Adding Jupyter Notebook Integration
export PYSPARK_DRIVER_PYTHON=/usr/local/bin/jupyter
export PYSPARK_DRIVER_PYTHON_OPTS="notebook --NotebookApp.open_browser=False --NotebookApp.ip='*' --NotebookApp.port=8880 --allow-root"
export PYSPARK_PYTHON=/usr/bin/python


echo "**********************************************************************************************************"
echo "[HELK INFO] Your HELK has been installed"
echo "[HELK INFO] Browse to your host IP  address from a different computer and enter the following credentials:"
echo "username: helk"
echo "password: hunting"
echo " "
echo "HAPPY HUNTING!!!!!"
echo "**********************************************************************************************************"