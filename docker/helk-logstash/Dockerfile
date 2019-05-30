# HELK script: HELK Logstash Dockerfile
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# References:
# https://cyberwardog.blogspot.com/2017/02/setting-up-pentesting-i-mean-threat_98.html

FROM docker.elastic.co/logstash/logstash:7.1.0
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for the HELK Logstash."

RUN mv /usr/share/logstash/config/logstash.yml /usr/share/logstash/config/logstash.yml.backup
COPY --chown=logstash:logstash config/logstash.yml /usr/share/logstash/config/logstash.yml