# HELK script: HELK Elasticsearch Dockerfile
# HELK build version: 0.9 (ALPHA)
# HELK ELK version: 6.2.4
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

# References: 
# https://cyberwardog.blogspot.com/2017/02/setting-up-pentesting-i-mean-threat_98.html

# *********** ELK Version ***************

FROM docker.elastic.co/elasticsearch/elasticsearch:6.2.4
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for the HELK Elasticsearch."

RUN mv /usr/share/elasticsearch/config/elasticsearch.yml /usr/share/elasticsearch/config/backup_elasticsearch
ADD elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml