# Dockerfile for Kibana
# Author: Roberto Rodriguez @Cyb3rWard0g

FROM debian:jessie
RUN apt-get update && apt-get install kibana && \
	mv /etc/kibana/kibana.yml /etc/kibana/backup_kibana.yml

ADD ../kibana.yml /etc/kibana/kibana.yml

RUN systemctl daemon-reload && \
	systemctl enable kibana.service && \
	systemctl start kibana.service