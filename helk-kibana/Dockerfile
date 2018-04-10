# HELK script: HELK Kibana Dockerfile
# HELK build version: 0.9 (ALPHA)
# HELK ELK version: 6.2.3
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

# References: 
# https://cyberwardog.blogspot.com/2017/02/setting-up-pentesting-i-mean-threat_98.html
# https://github.com/spujadas/elk-docker/blob/master/Dockerfile

FROM cyb3rward0g/helk-base:0.0.1
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for the HELK Kibana."

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
RUN bash -c 'mkdir -pv /opt/helk/{dashboards,kibana}'

# *********** Adding HELK scripts and files to Container ***************
ADD scripts/entrypoint.sh /opt/helk/scripts/
RUN chmod +x /opt/helk/scripts/entrypoint.sh

# *********** Adding HELK scripts and files to Container ***************
ADD scripts/elk-kibana-setup.sh /opt/helk/scripts/
ADD scripts/entrypoint.sh /opt/helk/scripts/
RUN chmod +x /opt/helk/scripts/elk-kibana-setup.sh
RUN chmod +x /opt/helk/scripts/entrypoint.sh

# *********** ELK Version ***************
ENV ELK_VERSION=6.2.3

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
ADD kibana-init /etc/init.d/kibana
ADD kibana.yml ${KIBANA_PATH_CONF}
ADD dashboards/ /opt/helk/dashboards/
RUN groupadd -r kibana -g ${KIBANA_GID} \
  && useradd -r -s /usr/sbin/nologin -M -c "Kibana user" -u ${KIBANA_UID} -g kibana kibana \
  && chown -R kibana:kibana ${KIBANA_HOME} ${KIBANA_PATH_CONF} ${KIBANA_PATH_LOGS} /opt/helk/dashboards

# *********** RUN HELK ***************
WORKDIR "/opt/helk/scripts/"
ENTRYPOINT ["./entrypoint.sh"]