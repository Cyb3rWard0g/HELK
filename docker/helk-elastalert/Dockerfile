# HELK script: HELK Elastalert Dockerfile
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# References: 
# https://github.com/Yelp/elastalert/blob/master/Dockerfile-test
# https://jordanpotti.com/2017/12/22/using-elastalert-to-help-automate-threat-hunting/

FROM otrf/helk-base:0.0.4
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for the HELK Elastalert."

ENV ESALERT_GID=910
ENV ESALERT_UID=910
ENV ESALERT_USER=elastalertuser
ENV ESALERT_HOME=/etc/elastalert
ENV ESALERT_SIGMA_HOME=/opt/sigma

# *********** Installing Prerequisites ***************
# -qq : No output except for errors
RUN apt-get update -qq && apt-get install -qqy --no-install-recommends \
  libmagic-dev \
  build-essential \
  python3-setuptools \
  git \
  python3-pip \
  python3-dev \
  python3-setuptools \
  tzdata \
  # ********* Clean ****************************
  && apt-get -qy clean \
  autoremove \
  && rm -rf /var/lib/apt/lists/* \
  # ********* Install Elastalert **************
  && git clone https://github.com/Yelp/elastalert.git ${ESALERT_HOME} \
  && bash -c 'mkdir -pv /etc/elastalert/rules' \
  && cd ${ESALERT_HOME} \
  && sudo pip3 install --upgrade pip \
  && sudo pip3 install --upgrade setuptools \
  && pip3 install urllib3 \
  && pip3 install -U enum34 \
  && pip3 install -r requirements.txt \
  && python3 setup.py install \
  # ********* Download SIGMA *******************
  && pip3 install -U sigmatools \
  && git clone https://github.com/Cyb3rWard0g/sigma.git ${ESALERT_SIGMA_HOME}

# ********* Copy Elastalert files **************
COPY scripts/* ${ESALERT_HOME}/
COPY config.yaml ${ESALERT_HOME}/
COPY rules/* ${ESALERT_HOME}/rules/
COPY sigmac/sigmac-config.yml ${ESALERT_SIGMA_HOME}/sigmac-config.yml

RUN chmod +x ${ESALERT_HOME}/pull-sigma.sh \
  # ********* Adding Elastalert User *************
  && groupadd -g ${ESALERT_GID} ${ESALERT_USER} \
  && useradd -u ${ESALERT_UID} -g ${ESALERT_GID} -d ${ESALERT_HOME} --no-create-home -s /bin/bash ${ESALERT_USER} \
  && chown -R ${ESALERT_USER}:${ESALERT_USER} ${ESALERT_HOME} ${ESALERT_SIGMA_HOME}

USER elastalertuser

# *********** RUN Elastalert ***************
WORKDIR ${ESALERT_HOME}
ENTRYPOINT ["./elastalert-entrypoint.sh"]
CMD ["/bin/bash","-c","elastalert","--verbose"]
