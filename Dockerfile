# HELK script: HELK Dockerfile
# HELK script description: Dockerize the HELK build
# HELK build version: 0.9 (BETA)
# HELK ELK version: 6.x
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

# References: 
# https://cyberwardog.blogspot.com/2017/02/setting-up-pentesting-i-mean-threat_98.html
# https://github.com/spujadas/elk-docker/blob/master/Dockerfile

FROM phusion/baseimage
MAINTAINER Roberto Rodriguez @Cyb3rWard0g
LABEL description="Dockerfile base for the HELK."

ENV DEBIAN_FRONTEND noninteractive

# *********** Installing Prerequisites ***************
# -qq : No output except for errors
RUN echo "[HELK-DOCKER-INSTALLATION-INFO] Updating Ubuntu base image.." \
  && apt-get update -qq \
  && echo "[HELK-DOCKER-INSTALLATION-INFO] Extracting templates from packages.." \
  && apt-get install -qqy \
  openjdk-8-jre-headless \
  wget \
  sudo \
  nano \
  apt-transport-https \
  python \
  python-pip \
  unzip
RUN apt-get -qy clean \
  autoremove

# *********** Upgrading PIP ***************
RUN pip install --upgrade pip

# *********** Installing AlienVault OTX Python SDK & Pandas ***************
RUN pip install \
  OTXv2 \
  pandas \
  jupyter

# *********** Creating the right directories ***************
RUN bash -c 'mkdir -pv /opt/helk/{scripts,otx,es-hadoop,spark,output_templates,dashboards}'

# *********** Adding HELK scripts to Container ***************
ADD scripts/ /opt/helk/scripts/

# *********** Setting Elastic packages definitions ***************
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add - \
  # Before installing elasticsearch, we have to set the elastic packages definitions to our source list.
  # For this step, elastic recommends to have "apt-transport-https" installed already or install it before adding the elasticsearch apt repository source list definition to your /etc/apt/sources.list
  && echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list \
  && apt-get update -qq

# *********** Installing Elasticsearch ***************
RUN apt-get install -qq elasticsearch \
  && mv /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/backup_elasticsearch.yml
ADD elasticsearch/docker/elasticsearch.yml /etc/elasticsearch/
RUN apt-get update -qq
VOLUME /var/lib/elasticsearch

# *********** Installing Kibana ***************
RUN apt-get install -qq kibana \
  && mv /etc/kibana/kibana.yml /etc/kibana/backup_kibana.yml
ADD kibana/kibana.yml /etc/kibana/ 

# *********** Adding Kibana dashboards files ***************
ADD kibana/dashboards/ /opt/helk/dashboards/

# *********** Installing Nginx ***************
RUN apt-get install -qqy nginx \
  && mv /etc/nginx/sites-available/default /etc/nginx/sites-available/backup_default
ADD nginx/htpasswd.users /etc/nginx/ 
ADD nginx/default /etc/nginx/sites-available/
RUN apt-get update -qq

# *********** Copying Intel files to HELK ***************
ADD enrichments/otx/ /opt/helk/otx/

# *********** Creating Cron Job to run OTX script every monday at 8AM and capture last 30 days of Intel *************
RUN cronjob="0 8 * * 1 python /opt/helk/scripts/helk_otx.py" \
  && echo "$cronjob" | crontab

# *********** Installing Logstash ***************
RUN apt-get install -qqy logstash
ADD logstash/output_templates/ /opt/helk/output_templates/
ADD logstash/pipeline/* /etc/logstash/conf.d/
ADD logstash/logstash-init /etc/init.d/logstash

# *********** Install ES-Hadoop ***************
RUN wget http://download.elastic.co/hadoop/elasticsearch-hadoop-6.1.1.zip -P /opt/helk/es-hadoop/ \
  && unzip /opt/helk/es-hadoop/*.zip -d /opt/helk/es-hadoop/ \
  && rm /opt/helk/es-hadoop/*.zip

# *********** Install Spark ***************
RUN wget -qO- http://mirrors.gigenet.com/apache/spark/spark-2.2.1/spark-2.2.1-bin-hadoop2.7.tgz | sudo tar xvz -C /opt/helk/spark/
ADD spark/.bashrc ~/.bashrc
ADD spark/log4j.properties /opt/helk/spark/spark-2.2.1-bin-hadoop2.7/conf/
ADD spark/spark-defaults.conf /opt/helk/spark/spark-2.2.1-bin-hadoop2.7/conf/

# Adding SPARK location
ENV SPARK_HOME=/opt/helk/spark/spark-2.2.1-bin-hadoop2.7
ENV PATH=$SPARK_HOME/bin:$PATH

# Adding Jupyter Notebook Integration
ENV PYSPARK_DRIVER_PYTHON=/usr/local/bin/jupyter
ENV PYSPARK_DRIVER_PYTHON_OPTS="notebook --NotebookApp.open_browser=False --NotebookApp.ip='*' --NotebookApp.port=8880 --allow-root"
ENV PYSPARK_PYTHON=/usr/bin/python

# *********** RUN HELK ***************
EXPOSE 80 5044 4040 8880
WORKDIR "/opt/helk/scripts/"
ENTRYPOINT ["./helk_docker_entrypoint.sh"]