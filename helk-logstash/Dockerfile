# HELK script: HELK Logstash Dockerfile
# HELK build version: 0.9 (ALPHA)
# HELK ELK version: 6.2.3
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

# References: 
# https://cyberwardog.blogspot.com/2017/02/setting-up-pentesting-i-mean-threat_98.html
# https://github.com/spujadas/elk-docker/blob/master/Dockerfile

FROM cyb3rward0g/helk-base:0.0.1
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for the HELK Logstash."

ENV DEBIAN_FRONTEND noninteractive

# *********** Installing Prerequisites ***************
# -qq : No output except for errors
RUN echo "[HELK-DOCKER-INSTALLATION-INFO] Updating Ubuntu base image.." \
  && apt-get update -qq \
  && echo "[HELK-DOCKER-INSTALLATION-INFO] Extracting templates from packages.." \
  && apt-get install -qqy \
  openjdk-8-jre-headless \
  python-pip

RUN apt-get -qy clean \
  autoremove

# *********** Creating the right directories ***************
RUN bash -c 'mkdir -pv /opt/helk/{output_templates,logstash}'

# *********** Adding HELK scripts and files to Container ***************
ADD scripts/entrypoint.sh /opt/helk/scripts/
RUN chmod +x /opt/helk/scripts/entrypoint.sh

# *********** ELK Version ***************
ENV ELK_VERSION=6.2.3

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
ADD logstash-init /etc/init.d/logstash
ADD pipeline/* ${LS_CONF_PATH}/
ADD logstash.yml ${LS_SETTINGS_DIR}
ADD output_templates/* /opt/helk/output_templates/
RUN groupadd -r logstash -g ${LS_GID} \
  && useradd -r -s /usr/sbin/nologin -M -c "Logstash user" -u ${LS_UID} -g logstash logstash \
  && chown -R logstash:logstash ${LS_HOME} ${LS_SETTINGS_DIR} ${LS_CONF_PATH} ${LS_LOGS_PATH} /opt/helk/output_templates

# *********** RUN HELK ***************
EXPOSE 5044
WORKDIR "/opt/helk/scripts/"
ENTRYPOINT ["./entrypoint.sh"]