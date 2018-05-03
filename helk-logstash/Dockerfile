# HELK script: HELK Logstash Dockerfile
# HELK build version: 0.9 (ALPHA)
# HELK ELK version: 6.2.4
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

# References: 
# https://cyberwardog.blogspot.com/2017/02/setting-up-pentesting-i-mean-threat_98.html
# https://github.com/spujadas/elk-docker/blob/master/Dockerfile

FROM docker.elastic.co/logstash/logstash:6.2.4
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for the HELK Logstash."

# *********** Adding HELK scripts, config files and pipeline configs to ontainer ***************
ADD logstash.yml /usr/share/logstash/config/logstash.yml
ADD pipeline /usr/share/logstash/pipeline
ADD output_templates /usr/share/logstash/output_templates

EXPOSE 5044