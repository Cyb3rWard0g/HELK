# HELK script: HELK Elasticsearch Dockerfile
# HELK build version: 0.9 (ALPHA)
# HELK ELK version: 6.2.3
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

# References: 
# https://cyberwardog.blogspot.com/2017/02/setting-up-pentesting-i-mean-threat_98.html
# https://github.com/spujadas/elk-docker/blob/master/Dockerfile

FROM cyb3rward0g/helk-base:0.0.1
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for the HELK Elasticsearch."

ENV DEBIAN_FRONTEND noninteractive

# *********** Installing Prerequisites ***************
# -qq : No output except for errors
RUN echo "[HELK-DOCKER-INSTALLATION-INFO] Updating Ubuntu base image.." \
  && apt-get update -qq \
  && echo "[HELK-DOCKER-INSTALLATION-INFO] Extracting templates from packages.." \
  && apt-get install -qqy \
  openjdk-8-jre-headless

RUN apt-get -qy clean \
  autoremove

# *********** Creating the right directories ***************
RUN bash -c 'mkdir -pv /opt/helk/{elasticsearch,cerebro}'

# *********** Adding HELK scripts and files to Container ***************
ADD scripts/entrypoint.sh /opt/helk/scripts/
RUN chmod +x /opt/helk/scripts/entrypoint.sh

# *********** ELK Version ***************
ENV ELK_VERSION=6.2.3

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
ADD elasticsearch /etc/default/elasticsearch
ADD elasticsearch-init /etc/init.d/elasticsearch
ADD elasticsearch.yml /etc/elasticsearch/
RUN groupadd -r elasticsearch -g ${ES_GID} \
  && useradd -r -s /usr/sbin/nologin -M -c "Elasticsearch user" -u ${ES_UID} -g elasticsearch elasticsearch \
  && chown -R elasticsearch:elasticsearch ${ES_HOME} ${ES_PATH_CONF} ${ES_PATH_DATA} ${ES_PATH_LOGS}

VOLUME /var/lib/elasticsearch

# *********** Install Cerebro ***************
ENV CEREBRO_HOME=/opt/helk/cerebro
ENV CEREBRO_LOGS_PATH=/var/log/cerebro
RUN wget -qO- https://github.com/lmenezes/cerebro/releases/download/v0.7.2/cerebro-0.7.2.tgz | sudo tar xvz -C ${CEREBRO_HOME} \
  && mkdir -v $CEREBRO_LOGS_PATH
ADD cerebro-init /etc/init.d/cerebro

# *********** RUN HELK ***************
EXPOSE 9000
WORKDIR "/opt/helk/scripts/"
ENTRYPOINT ["./entrypoint.sh"]