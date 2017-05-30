# Dockerfile for Kibana
# Author: Roberto Rodriguez @Cyb3rWard0g

FROM debian:jessie

RUN apt-get update && \
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
	apt-get install -y --no-install-recommends apt-transport-https && \
	echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-5.x.list && \
	apt-get install -y --no-install-recommends kibana && \
	mv /etc/kibana/kibana.yml /etc/kibana/backup_kibana.yml

ADD kibana.yml /etc/kibana/kibana.yml

RUN systemctl restart kibana