# Docker File for the HELK
# HELK build version: 0.9 (BETA Script)
# Author: Roberto Rodriguez @Cyb3rWard0g

FROM phusion/baseimage
MAINTAINER Roberto Rodriguez @cyb3rward0g

ARG DEBIAN_FRONTEND=noninteractive


###########################################
############### UPDATES ###################
###########################################

RUN apt-get update && \
	apt-get clean
	

###########################################
############# DEPENDENCIES ################
###########################################

RUN \
	wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add - \
	&& apt-get install apt-transport-https \ 
	&& apt-get install -qqy openjdk-8-jdk \
	&& apt-get clean

###########################################
############ ELASTICSEARCH ################
###########################################

RUN \
	echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list \
	&& apt-get update \
	&& apt-get install elasticsearch \
	&& mv /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/backup_elasticsearch.yml

ADD	elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml


###########################################
################ KIBANA ###################
###########################################

RUN \
	apt-get update \
	&& apt-get install kibana \
	&& mv /etc/kibana/kibana.yml /etc/kibana/backup_kibana.yml

ADD kibana/kibana.yml /etc/kibana/kibana.yml


###########################################
################# NGINX ###################
###########################################

RUN \
	apt-get update \
	&& apt-get -y install nginx \
	&& mv /etc/nginx/sites-available/default /etc/nginx/sites-available/backup_default

ADD nginx/docker/htpasswd.users /etc/nginx/htpasswd.users
ADD nginx/default /etc/nginx/sites-available/default


###########################################
###############  LOGSTASH #################
###########################################

RUN \
	apt-get update \
	&& apt-get install logstash

ADD logstash/pipeline/02-beats-input.conf /etc/logstash/conf.d/02-beats-input.conf
ADD logstash/pipeline/03-ace-rabbitmq-input.conf /etc/logstash/conf.d/03-ace-rabbitmq-input.conf
ADD logstash/pipeline/10-powershell-filter.conf /etc/logstash/conf.d/10-powershell-filter.conf
ADD logstash/pipeline/50-elasticsearch-output.conf /etc/logstash/conf.d/50-elasticsearch-output.conf
ADD logstash/pipeline/51-rabbitmq-elasticsearch-output.conf /etc/logstash/conf.d/51-rabbitmq-elasticsearch-output.conf



###########################################
################  START ###################
###########################################

ADD scripts/helk_docker_start.sh /usr/local/bin/helk_docker_start.sh
RUN chmod +x /usr/local/bin/helk_docker_start.sh

EXPOSE 80

CMD [ "/usr/local/bin/helk_docker_start.sh"]
