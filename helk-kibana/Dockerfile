# HELK script: HELK Kibana Dockerfile
# HELK build version: 0.9 (ALPHA)
# HELK ELK version: 6.2.4
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

# References: 
# https://cyberwardog.blogspot.com/2017/02/setting-up-pentesting-i-mean-threat_98.html
# https://github.com/spujadas/elk-docker/blob/master/Dockerfile

FROM docker.elastic.co/kibana/kibana:6.2.4
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for the HELK Kibana."

# *********** Adding HELK scripts to container ***************
ADD scripts/kibana-entrypoint.sh /usr/share/kibana/kibana-entrypoint.sh
ADD scripts/kibana-setup.sh /usr/share/kibana/kibana-setup.sh

# *********** RUN HELK Kibana ***************
WORKDIR "/usr/share/kibana/"
ENTRYPOINT ["./kibana-entrypoint.sh"]