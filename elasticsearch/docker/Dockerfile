# Dockerfile for Elasticsearch
# Author: Roberto Rodriguez @Cyb3rWard0g

FROM openjdk:8-jre

RUN apt-get update && apt-get install wget && \
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
	apt-get install -y apt-transport-https && \
	echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-5.x.list && \
	apt-get install elasticsearch && \
	mv /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/backup_elasticsearch.yml

ADD ../elasticsearch.yml /etc/elasticsearch/elasticsearch.yml

RUN systemctl daemon-reload && \
	systemctl enable elasticsearch.service && \
	systemctl start elasticsearch.service
	
