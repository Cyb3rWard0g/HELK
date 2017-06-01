# Dockerfile for  HELK
# Author: Roberto Rodriguez @Cyb3rWard0g

FROM openjdk:8-jre

ARG DEBIAN_FRONTEND=noninteractive 

RUN apt-get update && \
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
	apt-get install -y --no-install-recommends apt-transport-https && \
	echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-5.x.list && \
	apt-get install -y --no-install-recommends elasticsearch 

RUN apt-get update && apt-get install -y kibana 
RUN apt-get install -y logstash 
RUN apt-get install -y nginx && \
	echo "helkadmin:`openssl passwd -apr1 hunting`" | tee -a /etc/nginx/htpasswd.users && \
	mv /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/backup_elasticsearch.yml && \
	mv /etc/kibana/kibana.yml /etc/kibana/backup_kibana.yml && \
	mv /etc/nginx/sites-available/default /etc/nginx/sites-available/backup_default

ADD ./elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
ADD ./kibana/kibana.yml /etc/kibana/kibana.yml
ADD ./nginx/default /etc/nginx/sites-available/default
ADD ./logstash/02-beats-input.conf /etc/logstash/conf.d/02-beats-input.conf
ADD ./logstash50-elasticsearch-output.conf /etc/logstash/conf.d/50-elasticsearch-output.conf
ADD start_service.sh /start.sh

CMD ["./start.sh"]

EXPOSE 80

