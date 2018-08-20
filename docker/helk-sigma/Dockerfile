# HELK script: HELK Enrichments Dockerfile
# HELK build Stage: Alpha
# Author: Thomas Patzke
# License: GPL-3.0

# References: 
# https://github.com/Neo23x0/sigma

FROM cyb3rward0g/helk-base:0.0.1
LABEL maintainer="Thomas Patzke"
LABEL description="Dockerfile for Sigma integration"

ENV DEBIAN_FRONTEND noninteractive

# *********** Installing Prerequisites ***************
# -qq : No output except for errors
RUN apt-get update -qq \
  && apt-get install -qqy \
  python3-pip \
  unzip \
  git \
  jq

# *********** Upgrading PIP ***************
RUN pip3 install --upgrade pip

# *********** Creating directories ***************
RUN bash -c 'mkdir -pv /opt/sigma/{scripts,sigma}'

# *********** Adding entrypoint script to Container ***************
ADD scripts/sigma-entrypoint.sh /opt/sigma/scripts/
RUN chmod +x /opt/sigma/scripts/sigma-entrypoint.sh

# *********** Adding Sigma updater script to Container ***************
ADD scripts/update-sigma.sh /opt/sigma/scripts/
RUN chmod +x /opt/sigma/scripts/update-sigma.sh

# *********** Creating Cron Job to run Sigma script every monday at 8:00 AM and update the Sigma queries *************
RUN cronjob="0 8 * * 1 /opt/sigma/scripts/update-sigma.sh" \
  && (crontab -l; echo "$cronjob") | crontab

# *********** Pulling Sigma Git Repository and install Python dependencies *************
RUN git clone https://github.com/Neo23x0/sigma.git /opt/sigma/sigma
RUN pip3 install -r /opt/sigma/sigma/tools/requirements.txt

# *********** RUN HELK ***************
WORKDIR "/opt/sigma/scripts/"
ENTRYPOINT ["./sigma-entrypoint.sh"]
