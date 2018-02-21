#!/bin/bash

# HELK script: helk_debian_tar_install.sh
# HELK script description: Install all the needed components of the HELK via Tar File
# HELK build version: 0.9 (Alpha)
# HELK ELK version: 6.2.0
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

# References: 
# https://cyberwardog.blogspot.com/2017/02/setting-up-pentesting-i-mean-threat_98.html

# *********** Check if user is root ***************
if [[ $EUID -ne 0 ]]; then
   echo "[HELK-BASH-INSTALLATION-INFO] YOU MUST BE ROOT TO RUN THIS SCRIPT!!!" 
   exit 1
fi

# *********** Check System Kernel Name ***************
systemKernel="$(uname -s)"

if [ "$systemKernel" == "Linux" ]; then
    # *********** Check if debian-system is present ***************
    if [ -f /etc/debian_version ]; then
        echo "[HELK-BASH-INSTALLATION-INFO] This is a debian-based system.."
        echo "[HELK-BASH-INSTALLATION-INFO] Installing the HELK.."
    else
        echo "[HELK-BASH-INSTALLATION-INFO] This is not a debian-based system.."
        echo "[HELK-BASH-INSTALLATION-INFO] Install docker in your system and try to use one of the HELK's docker options.."
        exit 1
    fi
fi

# *********** Latest Supported ELK packages ***************
ELK_VERSION=6.2.0

# *********** HELK Installation Logs ***************
LOGFILE="/var/log/helk-install.log"

echoerror() {
    printf "${RC} * ERROR${EC}: $@\n" 1>&2;
}

echo "[HELK-BASH-INSTALLATION-INFO] Installing updates.."
apt-get update >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install updates (Error Code: $ERROR)."
        exit 1
    fi

# *********** Install Prerequisites ***************
echo "[HELK-BASH-INSTALLATION-INFO] Installing Prerequisites.."
declare -a prereq_list=("openjdk-8-jre-headless" "curl" "unzip" "python" "python-pip" "python-tk")
for prereq in ${!prereq_list[@]}; do 
    echo "[HELK-BASH-INSTALLATION-INFO] Installing ${prereq_list[${prereq}]}.."
    apt-get install -y ${prereq_list[${prereq}]} >> $LOGFILE 2>&1
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install ${prereq_list[${prereq}]} (Error Code: $ERROR)."
        exit 1
    fi
done

# *********** Upgrading Packages ***************
echo "[HELK-BASH-INSTALLATION-INFO] Upgrading pip.."
pip install --upgrade pip >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not upgrade pip (Error Code: $ERROR)."
        exit 1
    fi

# *********** Installing HELK Python packages ***************
echo "[HELK-BASH-INSTALLATION-INFO] Installing additional HELK python packages.."
pip install \
    OTXv2 \
    pandas==0.22.0 \
    jupyter >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install HELK python packages (Error Code: $ERROR)."
        exit 1
    fi

pip install \
    scipy==1.0.0 \
    scikit-learn==0.19.1 \
    nltk==3.2.5 \
    matplotlib==2.1.2 \
    seaborn==0.8.1 \
    datasketch==1.2.5 \
    tensorflow==1.5.0 \
    keras==2.1.3 \
    pyflux==0.4.15 \
    imbalanced-learn==0.3.2 \
    lime==0.1.1.29 \
	elasticsearch-curator==5.4.1 >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install HELK python packages (Error Code: $ERROR)."
        exit 1
    fi

# *********** Creating needed folders for the HELK ***************
echo "[HELK-BASH-INSTALLATION-INFO] Creating needed folders for the HELK.."
mkdir -pv /opt/helk/{scripts,training,otx,es-hadoop,spark,output_templates,dashboards,kafka,elasticsearch,logstash,kibana,cerebro,ksql,curator} >> $LOGFILE 2>&1
echo "[HELK-BASH-INSTALLATION-INFO] Copying HELK files over.."
cp -v helk_kibana_setup.sh /opt/helk/scripts/ >> $LOGFILE 2>&1
cp -v helk_otx.py /opt/helk/scripts/ >> $LOGFILE 2>&1
cp -vr ../training/* /opt/helk/training/ >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not create needed folders for the HELK (Error Code: $ERROR)."
        exit 1
    fi

# *********** Installing Elasticsearch ***************
ES_HELK_HOME=/opt/helk/elasticsearch
ES_HOME=/usr/share/elasticsearch
ES_PATH_CONF=/etc/elasticsearch
ES_PATH_DATA=/var/lib/elasticsearch
ES_PATH_LOGS=/var/log/elasticsearch
ES_GID=707
ES_UID=707

echo "[HELK-BASH-INSTALLATION-INFO] Downloading Elasticsearch ${ELK_VERSION} tar.gz package.."
wget -qO- https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ELK_VERSION}.tar.gz | sudo tar xvz -C ${ES_HELK_HOME} --strip-components=1 >> $LOGFILE 2>&1
echo "[HELK-BASH-INSTALLATION-INFO] Copying Elasticsearch home to ${ES_HOME} .."
cp -r ${ES_HELK_HOME}/ ${ES_HOME}/ >> $LOGFILE 2>&1
echo "[HELK-BASH-INSTALLATION-INFO] Creating Elasticsearch folders .."
mkdir -pv ${ES_PATH_CONF} ${ES_PATH_DATA} ${ES_PATH_LOGS} >> $LOGFILE 2>&1
echo "[HELK-BASH-INSTALLATION-INFO] copying custom elasticsearch config files to /etc/elasticsearch/.."
cp -v ../elasticsearch/elasticsearch /etc/default/elasticsearch >> $LOGFILE 2>&1
cp -v ../elasticsearch/elasticsearch-init /etc/init.d/elasticsearch >> $LOGFILE 2>&1
mv /usr/share/elasticsearch/config/* ${ES_PATH_CONF} >> $LOGFILE 2>&1
yes | cp -rfv ../elasticsearch/elasticsearch.yml ${ES_PATH_CONF} >> $LOGFILE 2>&1

echo "[HELK-BASH-INSTALLATION-INFO] Creating elasticsearch user and group.."
groupadd -r elasticsearch -g ${ES_GID}
useradd -r -s /usr/sbin/nologin -M -c "Elasticsearch user" -u ${ES_UID} -g elasticsearch elasticsearch
echo "[HELK-BASH-INSTALLATION-INFO] setting Elasticsearch permissions to folders.."
chown -R elasticsearch:elasticsearch ${ES_HOME} ${ES_PATH_CONF} ${ES_PATH_DATA} ${ES_PATH_LOGS}
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not set up elasticsearch environment (Error Code: $ERROR)."
        exit 1
    fi

    # *********** Setting ES Heap Size***************
    # https://serverfault.com/questions/881383/automatically-set-java-heap-size-for-elasticsearch-on-linux
echo "[HELK-BASH-INSTALLATION-INFO] Setting ES heap size to half of the available memory in your local system.."
memoryInKb="$(awk '/MemFree/ {print $2}' /proc/meminfo)"
heapSize="$(expr $memoryInKb / 1024 / 1000 / 2)"
sed -i "s/#*-Xmx[0-9]\+g/-Xmx${heapSize}g/g" /etc/elasticsearch/jvm.options >> $LOGFILE 2>&1
sed -i "s/#*-Xms[0-9]\+g/-Xms${heapSize}g/g" /etc/elasticsearch/jvm.options >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not set the ES Heap size... (Error Code: $ERROR)."
        exit 1
    fi

echo "[HELK-BASH-INSTALLATION-INFO] Starting elasticsearch and setting it to start automatically when the system boots.."
update-rc.d elasticsearch defaults 95 10 >> $LOGFILE 2>&1
service elasticsearch start >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not start elasticsearch and set elasticsearch to start automatically when the system boots (Error Code: $ERROR)."
        exit 1
    fi

# *********** Installing Kibana ***************
KIBANA_HELK_HOME=/opt/helk/kibana
KIBANA_HOME=/usr/share/kibana
KIBANA_PATH_CONF=/etc/kibana
KIBANA_PATH_LOGS=/var/log/kibana
KIBANA_GID=708
KIBANA_UID=708

echo "[HELK-BASH-INSTALLATION-INFO] Downloading Kibana ${ELK_VERSION} tar.gz package.."
wget -qO- https://artifacts.elastic.co/downloads/kibana/kibana-${ELK_VERSION}-linux-x86_64.tar.gz | sudo tar xvz -C ${KIBANA_HELK_HOME} --strip-components=1 >> $LOGFILE 2>&1
echo "[HELK-BASH-INSTALLATION-INFO] Copying Kibana home to ${KIBANA_HOME} .."
cp -r ${KIBANA_HELK_HOME}/ ${KIBANA_HOME}/ >> $LOGFILE 2>&1
echo "[HELK-BASH-INSTALLATION-INFO] Creating Kibana folders .."
mkdir -pv ${KIBANA_PATH_CONF} ${KIBANA_PATH_LOGS} >> $LOGFILE 2>&1
echo "[HELK-BASH-INSTALLATION-INFO] copying custom kibana config files.."
cp -v ../kibana/kibana-init /etc/init.d/kibana >> $LOGFILE 2>&1
mv /usr/share/kibana/config/* ${KIBANA_PATH_CONF} >> $LOGFILE 2>&1
yes | cp -rfv ../kibana/kibana.yml ${KIBANA_PATH_CONF} >> $LOGFILE 2>&1

echo "[HELK-BASH-INSTALLATION-INFO] Creating kibana user and group.."
groupadd -r kibana -g ${KIBANA_GID}
useradd -r -s /usr/sbin/nologin -M -c "Kibana user" -u ${KIBANA_UID} -g kibana kibana
echo "[HELK-BASH-INSTALLATION-INFO] setting Kibana permissions to folders.."
chown -R kibana:kibana ${KIBANA_HOME} ${KIBANA_PATH_CONF} ${KIBANA_PATH_LOGS} /opt/helk/dashboards/
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not set up Kibana environment (Error Code: $ERROR)."
        exit 1
    fi

echo "[HELK-BASH-INSTALLATION-INFO] Starting kibana and setting it to start automatically when the system boots.."
update-rc.d kibana defaults 96 9>> $LOGFILE 2>&1
service kibana start >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not start Kibana and set Kibana to start automatically when the system boots (Error Code: $ERROR)."
        exit 1
    fi

    # *********** Creating Kibana Index-patterns, Dashboards and Visualization ***************
echo "[HELK-BASH-INSTALLATION-INFO] Creating Kibana index-patterns, dashboards and visualizations automatically.."
cp -v ../kibana/dashboards/* /opt/helk/dashboards/ >> $LOGFILE 2>&1
./helk_kibana_setup.sh >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not create kibana index-patterns, dashboards or visualizations (Error Code: $ERROR)."
        exit 1
    fi

# *********** Installing Logstash ***************
LOGSTASH_HELK_HOME=/opt/helk/logstash
LS_HOME=/usr/share/logstash
LS_SETTINGS_DIR=/etc/logstash
LS_CONF_PATH=/etc/logstash/pipeline
LS_LOGS_PATH=/var/log/logstash
LS_GID=709
LS_UID=709

echo "[HELK-BASH-INSTALLATION-INFO] Downloading Logstash ${ELK_VERSION} tar.gz package.."
wget -qO- https://artifacts.elastic.co/downloads/logstash/logstash-${ELK_VERSION}.tar.gz | sudo tar xvz -C ${LOGSTASH_HELK_HOME} --strip-components=1 >> $LOGFILE 2>&1
echo "[HELK-BASH-INSTALLATION-INFO] Copying logstash home to ${LS_HOME} .."
cp -r ${LOGSTASH_HELK_HOME}/ ${LS_HOME}/ >> $LOGFILE 2>&1
echo "[HELK-BASH-INSTALLATION-INFO] Creating Logstash folders .."
mkdir -pv ${LS_SETTINGS_DIR} ${LS_CONF_PATH} ${LS_LOGS_PATH} >> $LOGFILE 2>&1
echo "[HELK-BASH-INSTALLATION-INFO] copying custom Logstash config files.."
cp -v ../logstash/logstash-init /etc/init.d/logstash >> $LOGFILE 2>&1
cp -av ../logstash/pipeline/* ${LS_CONF_PATH} >> $LOGFILE 2>&1
mv /usr/share/logstash/config/* ${LS_SETTINGS_DIR} >> $LOGFILE 2>&1
yes | cp -rfv ../logstash/logstash.yml ${LS_SETTINGS_DIR} >> $LOGFILE 2>&1
echo "[HELK-BASH-INSTALLATION-INFO] Creating templates directory and copying custom templates over.."
cp -v ../logstash/output_templates/* /opt/helk/output_templates/ >> $LOGFILE 2>&1 

echo "[HELK-BASH-INSTALLATION-INFO] Creating logstash user and group.."
groupadd -r logstash -g ${LS_GID}
useradd -r -s /usr/sbin/nologin -M -c "Logstash user" -u ${LS_UID} -g logstash logstash
echo "[HELK-BASH-INSTALLATION-INFO] setting Logstash permissions to folders.."
chown -R logstash:logstash ${LS_HOME} ${LS_SETTINGS_DIR} ${LS_CONF_PATH} ${LS_LOGS_PATH} /opt/helk/output_templates
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not set up Logstash environment (Error Code: $ERROR)."
        exit 1
    fi

    # *********** Setting Logstash Heap Size***************
    # https://www.elastic.co/guide/en/logstash/current/performance-troubleshooting.html
echo "[HELK-BASH-INSTALLATION-INFO] Setting Logstash JVM heap size to 2GB.."
sed -i "s/#*-Xmx[0-9]\+g/-Xmx2g/g" /etc/logstash/jvm.options >> $LOGFILE 2>&1
sed -i "s/#*-Xms[0-9]\+g/-Xms2g/g" /etc/logstash/jvm.options >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not set the Logstash JVM heap size... (Error Code: $ERROR)."
        exit 1
    fi

    # *********** Setting Logstash Workers ***************
# cpu_number="$(getconf _NPROCESSORS_ONLN)"
# LS_CONFIG_FILE=${LS_SETTINGS_DIR}/logstash.yml
# echo "[HELK-BASH-INSTALLATION-INFO] Setting Logstash pipeline workers to $cpu_number.."

echo "[HELK-BASH-INSTALLATION-INFO] Starting Logstash and setting it to start automatically when the system boots.."
update-rc.d logstash defaults 96 9>> $LOGFILE 2>&1
service logstash start >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not start Logstash and set Logstash to start automatically when the system boots (Error Code: $ERROR)."
        exit 1
    fi

# *********** Installing Nginx ***************
echo "[HELK-BASH-INSTALLATION-INFO] Installing Nginx.."
apt-get -y install nginx >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install kibana (Error Code: $ERROR)."
        exit 1
    fi    
echo "[HELK-BASH-INSTALLATION-INFO] Adding a htpasswd.users file to nginx.."
cp -v ../nginx/htpasswd.users /etc/nginx/ >> $LOGFILE 2>&1
echo "[HELK-BASH-INSTALLATION-INFO] Creating a backup of Nginx's config file.."
mv /etc/nginx/sites-available/default /etc/nginx/sites-available/backup_default >> $LOGFILE 2>&1   
echo "[HELK-BASH-INSTALLATION-INFO] copying custom nginx config file to /etc/nginx/sites-available/.."
cp -v ../nginx/default /etc/nginx/sites-available/ >> $LOGFILE 2>&1  
echo "[HELK-BASH-INSTALLATION-INFO] testing nginx configuration.."
nginx -t >> $LOGFILE 2>&1

echo "[HELK-BASH-INSTALLATION-INFO] Restarting nginx service.."
service nginx restart >> $LOGFILE 2>&1
update-rc.d nginx defaults 96 9
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not set up Nginx configs (Error Code: $ERROR)."
        exit 1
    fi

echo "[HELK-BASH-INSTALLATION-INFO] Installing updates.."
apt-get update >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install update (Error Code: $ERROR)."
        exit 1
    fi

# *********** Installing AlienVault OTX Python SDK ***************
echo "[HELK-BASH-INSTALLATION-INFO] Copying AlienVault Intel files to HELK"
cp -v ../enrichments/otx/* /opt/helk/otx/ >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not copy intel files to HELK (Error Code: $ERROR)."
        exit 1
    fi

# *********** Creating Cron Job to run OTX script every monday at 8AM and capture last 30 days of Intel *************
echo "[HELK-BASH-INSTALLATION-INFO] Creating a cronjob for OTX intel script"
cronjob="0 8 * * 1 python /opt/helk/scripts/helk_otx.py"
echo "$cronjob" | crontab - >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not create cronjob for OTX intel script (Error Code: $ERROR)."
        exit 1
    fi

# *********** Install ES-Hadoop ***************
echo "[HELK-BASH-INSTALLATION-INFO] Downloading ES-Hadoop Connector.."
wget https://artifacts.elastic.co/downloads/elasticsearch-hadoop/elasticsearch-hadoop-6.2.0.zip -P /opt/helk/es-hadoop/ >> $LOGFILE 2>&1
unzip /opt/helk/es-hadoop/*.zip -d /opt/helk/es-hadoop/ >> $LOGFILE 2>&1
rm /opt/helk/es-hadoop/*.zip >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install ES-Hadoop (Error Code: $ERROR)."
        exit 1
    fi

# *********** Install Spark ***************
SPARK_HOME=/opt/helk/spark/spark-2.2.1-bin-hadoop2.7
SPARK_LOGS_PATH=/var/log/spark

echo "[HELK-BASH-INSTALLATION-INFO] Downloading Spark.."
sudo wget -qO- http://mirrors.gigenet.com/apache/spark/spark-2.2.1/spark-2.2.1-bin-hadoop2.7.tgz | sudo tar xvz -C /opt/helk/spark/ >> $LOGFILE 2>&1
echo "[HELK-BASH-INSTALLATION-INFO] Creating Spark log folder .."
mkdir -v ${SPARK_LOGS_PATH} >> $LOGFILE 2>&1
echo "[HELK-BASH-INSTALLATION-INFO] Copying custom spark files"
cp -f ../spark/.bashrc ~/.bashrc >> $LOGFILE 2>&1
cp -v ../spark/log4j.properties /opt/helk/spark/spark-2.2.1-bin-hadoop2.7/conf/ >> $LOGFILE 2>&1
cp -v ../spark/spark-defaults.conf /opt/helk/spark/spark-2.2.1-bin-hadoop2.7/conf/ >> $LOGFILE 2>&1

echo "[HELK-BASH-INSTALLATION-INFO] Adding Spark environment variables.."
# Adding SPARK location
export SPARK_HOME=/opt/helk/spark/spark-2.2.1-bin-hadoop2.7
export PATH=$SPARK_HOME/bin:$PATH

echo "[HELK-BASH-INSTALLATION-INFO] Adding PySpark environment variables.."
# Adding Jupyter Notebook Integration
export PYSPARK_DRIVER_PYTHON=/usr/local/bin/jupyter
export PYSPARK_DRIVER_PYTHON_OPTS="notebook --NotebookApp.open_browser=False --NotebookApp.ip='*' --NotebookApp.port=8880 --allow-root"
export PYSPARK_PYTHON=/usr/bin/python

echo "[HELK-BASH-INSTALLATION-INFO] Starting spark and setting it to start automatically when the system boots.."
cp -v ../spark/spark-init /etc/init.d/spark >> $LOGFILE 2>&1
update-rc.d spark defaults 96 9
service spark start >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install spark (Error Code: $ERROR)."
        exit 1
    fi

# *********** Install Kafka ***************
KAFKA_LOGS_PATH=/var/log/kafka

echo "[HELK-BASH-INSTALLATION-INFO] Downloading Kafka package.."
wget -qO- http://apache.mirrors.lucidnetworks.net/kafka/1.0.0/kafka_2.11-1.0.0.tgz | sudo tar xvz -C /opt/helk/kafka/ >> $LOGFILE 2>&1
echo "[HELK-BASH-INSTALLATION-INFO] Creating Kafka log folder .."
mkdir -v ${KAFKA_LOGS_PATH} >> $LOGFILE 2>&1
echo "[HELK-BASH-INSTALLATION-INFO] Creating a backup of default server.properties" 
mv /opt/helk/kafka/kafka_2.11-1.0.0/config/server.properties /opt/helk/kafka/kafka_2.11-1.0.0/config/backup_server.properties >> $LOGFILE 2>&1
echo "[HELK-BASH-INSTALLATION-INFO] Copying custom server.properties and custom files" 
cp -v ../kafka/*.properties /opt/helk/kafka/kafka_2.11-1.0.0/config/ >> $LOGFILE 2>&1
cp -v ../kafka/kafka-init /etc/init.d/kafka >> $LOGFILE 2>&1

echo "[HELK-BASH-INSTALLATION-INFO] Obtaining current host IP.."
host_ip=$(ip route get 1 | awk '{print $NF;exit}')
echo "[HELK-BASH-INSTALLATION-INFO] Setting current host IP to brokers server.properties files.."
sed -i "s/advertised\.listeners\=PLAINTEXT:\/\/HELKIP\:9092/advertised\.listeners\=PLAINTEXT\:\/\/${host_ip}\:9092/g" /opt/helk/kafka/kafka_2.11-1.0.0/config/server.properties >> $LOGFILE 2>&1
sed -i "s/advertised\.listeners\=PLAINTEXT:\/\/HELKIP\:9093/advertised\.listeners\=PLAINTEXT\:\/\/${host_ip}\:9093/g" /opt/helk/kafka/kafka_2.11-1.0.0/config/server-1.properties >> $LOGFILE 2>&1
sed -i "s/advertised\.listeners\=PLAINTEXT:\/\/HELKIP\:9094/advertised\.listeners\=PLAINTEXT\:\/\/${host_ip}\:9094/g" /opt/helk/kafka/kafka_2.11-1.0.0/config/server-2.properties >> $LOGFILE 2>&1

echo "[HELK-BASH-INSTALLATION-INFO] Starting Kafka and setting it to start automatically when the system boots.."
echo "[HELK-BASH-INSTALLATION-INFO] Setting preferIPv4Stack to True.."
update-rc.d kafka defaults 96 9
service kafka start >> $LOGFILE 2>&1
sleep 25
echo "[HELK-BASH-INSTALLATION-INFO] Creating Kafka Winlogbeat Topic.."
/opt/helk/kafka/kafka_2.11-1.0.0/bin/kafka-topics.sh --create --zookeeper $host_ip:2181 --replication-factor 3 --partitions 1 --topic winlogbeat >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install kafka (Error Code: $ERROR)."
        exit 1
    fi

# *********** Download KSQL (Experiment) ***************
#echo "[HELK-BASH-INSTALLATION-INFO] Downloading KSQL package.."
#wget -qO- https://github.com/confluentinc/ksql/archive/v0.4.tar.gz | sudo tar xvz -C /opt/helk/ksql/ >> $LOGFILE 2>&1

# *********** Install Cerebro***************
CEREBRO_HOME=/opt/helk/cerebro
CEREBRO_LOGS_PATH=/var/log/cerebro

echo "[HELK-BASH-INSTALLATION-INFO] Downloading Cerebro package.."
wget -qO- https://github.com/lmenezes/cerebro/releases/download/v0.7.2/cerebro-0.7.2.tgz | sudo tar xvz -C ${CEREBRO_HOME} >> $LOGFILE 2>&1
echo "[HELK-BASH-INSTALLATION-INFO] Creating Kafka log folder .."
mkdir -v ${CEREBRO_LOGS_PATH} >> $LOGFILE 2>&1
echo "[HELK-BASH-INSTALLATION-INFO] Starting Cerebro and setting it to start automatically when the system boots.."
cp -v ../cerebro/cerebro-init /etc/init.d/cerebro >> $LOGFILE 2>&1
update-rc.d cerebro defaults 96 9
service cerebro start >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install cerebro (Error Code: $ERROR)."
        exit 1
    fi

echo "[HELK-BASH-INSTALLATION-INFO] HELK installation completed.."

# *********** Configure Curator***************

echo "[HELK-BASH-INSTALLATION-INFO] Creating a cronjob for curator"
cronjob="0 0 * * * /usr/local/bin/curator --config /opt/helk/curator/config.yml /opt/helk/curator/delete-after.yml"
echo "$cronjob" | crontab - >> $LOGFILE 2>&1
cronjob2="0 * * * 0 /usr/local/bin/curator --config /opt/helk/curator/config.yml /opt/helk/curator/forcemerge.yml"
echo "$cronjob2" | crontab - >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not create cronjob for curator (Error Code: $ERROR)."
        exit 1
    fi

