# Dockerfile for Logstash
# Author: Roberto Rodriguez @Cyb3rWard0g

FROM openjdk:8-jre

RUN apt-get update && \
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
	apt-get install -y --no-install-recommends apt-transport-https && \
	echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-5.x.list && \
	apt-get update && apt-get install -y --no-install-recommends logstash

ADD 02-beats-input.conf /etc/logstash/conf.d/02-beats-input.conf
ADD 50-elasticsearch-output.conf /etc/logstash/conf.d/50-elasticsearch-output.conf

EXPOSE 5044

CMD ["/bin/systemctl", "start", "logstash"]
