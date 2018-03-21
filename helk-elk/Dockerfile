# HELK script: HELK ELK Dockerfile
# HELK build version: 0.9 (ALPHA)
# HELK ELK version: 6.2.2
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

# References: 
# https://cyberwardog.blogspot.com/2017/02/setting-up-pentesting-i-mean-threat_98.html
# https://github.com/spujadas/elk-docker/blob/master/Dockerfile

FROM phusion/baseimage
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for the HELK ELK."

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
  python \
  python-pip \
  unzip

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen
RUN apt-get -qy clean \
  autoremove

# *********** Upgrading PIP ***************
RUN pip install --upgrade pip

# *********** Installing HELK python packages ***************
RUN pip install \
  OTXv2 \
  pandas==0.22.0

# *********** Creating the right directories ***************
#RUN bash -c 'mkdir -pv /opt/helk/{scripts,training,otx,es-hadoop,spark,output_templates,dashboards,kafka,elasticsearch,logstash,kibana,cerebro,ksql}'
RUN bash -c 'mkdir -pv /opt/helk/{scripts,otx,output_templates,dashboards,elasticsearch,logstash,kibana,cerebro,ksql}'

# *********** Adding HELK scripts and files to Container ***************
ADD scripts/helk_otx.py /opt/helk/scripts/
ADD scripts/elk-kibana-setup.sh /opt/helk/scripts/
ADD scripts/elk-entrypoint.sh /opt/helk/scripts/
RUN chmod +x /opt/helk/scripts/elk-kibana-setup.sh
RUN chmod +x /opt/helk/scripts/elk-entrypoint.sh

# *********** ELK Version ***************
ENV ELK_VERSION=6.2.2

# *********** Installing Elasticsearch ***************
ENV ES_HELK_HOME=/opt/helk/elasticsearch
ENV ES_HOME=/usr/share/elasticsearch
ENV ES_PATH_CONF=/etc/elasticsearch
ENV ES_PATH_DATA=/var/lib/elasticsearch
ENV ES_PATH_LOGS=/var/log/elasticsearch
ENV ES_GID=707
ENV ES_UID=707

RUN wget -qO- https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ELK_VERSION}.tar.gz | sudo tar xvz -C ${ES_HELK_HOME} --strip-components=1 \
  && cp -r ${ES_HELK_HOME}/ ${ES_HOME}/ \
  && mkdir -pv ${ES_PATH_CONF} ${ES_PATH_DATA} ${ES_PATH_LOGS} \
  && mv /usr/share/elasticsearch/config/* ${ES_PATH_CONF}
ADD elasticsearch/elasticsearch /etc/default/elasticsearch
ADD elasticsearch/elasticsearch-init /etc/init.d/elasticsearch
ADD elasticsearch/elasticsearch.yml /etc/elasticsearch/
RUN groupadd -r elasticsearch -g ${ES_GID} \
  && useradd -r -s /usr/sbin/nologin -M -c "Elasticsearch user" -u ${ES_UID} -g elasticsearch elasticsearch \
  && chown -R elasticsearch:elasticsearch ${ES_HOME} ${ES_PATH_CONF} ${ES_PATH_DATA} ${ES_PATH_LOGS}

VOLUME /var/lib/elasticsearch

# *********** Installing Kibana ***************
ENV KIBANA_HELK_HOME=/opt/helk/kibana
ENV KIBANA_HOME=/usr/share/kibana
ENV KIBANA_PATH_CONF=/etc/kibana
ENV KIBANA_PATH_LOGS=/var/log/kibana
ENV KIBANA_GID=708
ENV KIBANA_UID=708

RUN wget -qO- https://artifacts.elastic.co/downloads/kibana/kibana-${ELK_VERSION}-linux-x86_64.tar.gz | sudo tar xvz -C ${KIBANA_HELK_HOME} --strip-components=1 \
  && cp -r ${KIBANA_HELK_HOME}/ ${KIBANA_HOME}/ \
  && mkdir -pv ${KIBANA_PATH_CONF} ${KIBANA_PATH_LOGS} \
  && mv /usr/share/kibana/config/* ${KIBANA_PATH_CONF}
ADD kibana/kibana-init /etc/init.d/kibana
ADD kibana/kibana.yml ${KIBANA_PATH_CONF}
ADD kibana/dashboards/ /opt/helk/dashboards/
RUN groupadd -r kibana -g ${KIBANA_GID} \
  && useradd -r -s /usr/sbin/nologin -M -c "Kibana user" -u ${KIBANA_UID} -g kibana kibana \
  && chown -R kibana:kibana ${KIBANA_HOME} ${KIBANA_PATH_CONF} ${KIBANA_PATH_LOGS} /opt/helk/dashboards

# *********** Installing Logstash ***************
ENV LOGSTASH_HELK_HOME=/opt/helk/logstash
ENV LS_HOME=/usr/share/logstash
ENV LS_SETTINGS_DIR=/etc/logstash
ENV LS_CONF_PATH=/etc/logstash/pipeline
ENV LS_LOGS_PATH=/var/log/logstash
ENV LS_GID=709
ENV LS_UID=709

RUN wget -qO- https://artifacts.elastic.co/downloads/logstash/logstash-${ELK_VERSION}.tar.gz | sudo tar xvz -C ${LOGSTASH_HELK_HOME} --strip-components=1 \
  && cp -r ${LOGSTASH_HELK_HOME}/ ${LS_HOME}/ \
  && mkdir -pv ${LS_SETTINGS_DIR} ${LS_CONF_PATH} ${LS_LOGS_PATH} \
  && mv /usr/share/logstash/config/* ${LS_SETTINGS_DIR}
ADD logstash/logstash-init /etc/init.d/logstash
ADD logstash/pipeline/* ${LS_CONF_PATH}/
ADD logstash/logstash.yml ${LS_SETTINGS_DIR}
ADD logstash/output_templates/* /opt/helk/output_templates/
RUN groupadd -r logstash -g ${LS_GID} \
  && useradd -r -s /usr/sbin/nologin -M -c "Logstash user" -u ${LS_UID} -g logstash logstash \
  && chown -R logstash:logstash ${LS_HOME} ${LS_SETTINGS_DIR} ${LS_CONF_PATH} ${LS_LOGS_PATH} /opt/helk/output_templates

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

# *********** Install Cerebro ***************
ENV CEREBRO_HOME=/opt/helk/cerebro
ENV CEREBRO_LOGS_PATH=/var/log/cerebro
RUN wget -qO- https://github.com/lmenezes/cerebro/releases/download/v0.7.2/cerebro-0.7.2.tgz | sudo tar xvz -C ${CEREBRO_HOME} \
  && mkdir -v $CEREBRO_LOGS_PATH
ADD cerebro/cerebro-init /etc/init.d/cerebro

# *********** RUN HELK ***************
EXPOSE 80 5044 9000 8082
WORKDIR "/opt/helk/scripts/"
ENTRYPOINT ["./elk-entrypoint.sh"]