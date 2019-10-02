# HELK script: HELK Curator Dockerfile
# HELK build Stage: Alpha
# Author: Ashlee Jones (@AshleeJones04)
# License: Apache 2.0

# References: 
# https://github.com/elastic/curator

FROM cyb3rward0g/helk-base:0.0.3
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for the HELK Curator."

ENV CURATOR_GID=934
ENV CURATOR_UID=934
ENV CURATOR_USER=curatoruser
ENV CURATOR_HOME=/usr/share/curator
ENV DEBIAN_FRONTEND noninteractive

# *********** Installing Prerequisites ***************
# -qq : No output except for errors
RUN apt-get update -qq && apt-get install -qqy --no-install-recommends \
  libmagic-dev \
  build-essential \
  python3-setuptools \
  git \
  python3-pip \
  python3-dev \
  tzdata \
  nano \
  cron \
  # ********* Clean ****************************
  && apt-get -qy clean \
  autoremove \
  && rm -rf /var/lib/apt/lists/* \
  # ********* Install Curator **************
  && bash -c 'mkdir -pv /usr/share/curator' \
  && cd ${CURATOR_HOME} \
  && wget https://raw.githubusercontent.com/elastic/curator/master/requirements.txt \
  && pip3 install wheel \
  && pip3 install -r requirements.txt \
  && pip3 install elasticsearch-curator

# ********* Copy Curator files and setup cron **************
COPY actions.yaml ${CURATOR_HOME}/
COPY curator.yml ${CURATOR_HOME}/
COPY helk-curator-cron /etc/cron.d/helk-curator-cron
RUN chmod 0644 /etc/cron.d/helk-curator-cron
RUN crontab /etc/cron.d/helk-curator-cron
RUN touch /var/log/helk-curator-cron.log


# *********** RUN Curator ***************
WORKDIR ${CURATOR_HOME}
#ENTRYPOINT ["./curator-entrypoint.sh"]
#CMD ["curator","--config","/usr/share/curator/curator.yml","/usr/share/curator/actions.yaml"]
CMD cron && tail -f /var/log/helk-curator-cron.log