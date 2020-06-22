# HELK script: HELK Logstash Dockerfile
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

FROM docker.elastic.co/logstash/logstash:7.7.1
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for the HELK Logstash."

ENV LOGSTASH_PACK_URL=https://artifacts.elastic.co/downloads/logstash-plugins

# Backup configuration files then add/copy HELK configurations
RUN mv /usr/share/logstash/config/logstash.yml /usr/share/logstash/config/logstash.yml.bak && \
mv /usr/share/logstash/config/pipelines.yml /usr/share/logstash/config/pipelines.yml.bak && \
mv /usr/share/logstash/config/log4j2.properties /usr/share/logstash/config/log4j2.properties.bak && \
mv /usr/share/logstash/config/startup.options /usr/share/logstash/config/startup.options.bak && \
mv /usr/share/logstash/pipeline/logstash.conf /usr/share/logstash/pipeline/logstash.conf.bak
##COPY --chown=logstash:logstash config/logstash.yml /usr/share/logstash/config/logstash.yml
##COPY --chown=logstash:logstash config/pipelines.yml /usr/share/logstash/config/pipelines.yml
##COPY --chown=logstash:logstash config/log4j2.properties /usr/share/logstash/config/log4j2.properties
##COPY --chown=logstash:logstash config/startup.options /usr/share/logstash/config/startup.options
COPY --chown=logstash:logstash config /usr/share/logstash/config

# Build with plugins baked in
#ENV plugins_time_file="/usr/share/logstash/helk-plugins-updated-timestamp.txt"
#RUN printf "%s" "$(date +"%Y-%m-%d %T")" > "${plugins_time_file}"
#RUN chown logstash:logstash "${plugins_time_file}"

COPY --chown=logstash:logstash \
  plugins/helk-offline-logstash-codec_and_filter_plugins.zip \
  plugins/helk-offline-logstash-input-plugins.zip \
  plugins/helk-offline-logstash-output-plugins.zip \
  /usr/share/logstash/plugins/
RUN logstash-plugin install file:///usr/share/logstash/plugins/helk-offline-logstash-codec_and_filter_plugins.zip \
    && logstash-plugin install file:///usr/share/logstash/plugins/helk-offline-logstash-input-plugins.zip \
    && logstash-plugin install file:///usr/share/logstash/plugins/helk-offline-logstash-output-plugins.zip \
    && rm plugins/helk-offline* \
    && rm -rf /tmp/bundler \
    && rm -rf /usr/share/logstash/vendor/bundle/jruby/2.5.0/cache/*

## Remove uncessary plugins
#RUN ./bin/logstash-plugin remove logstash-input-couchdb_changes; \
#  ./bin/logstash-plugin remove logstash-input-gelf; \
#  ./bin/logstash-plugin remove logstash-input-ganglia; \
#  ./bin/logstash-plugin remove logstash-input-graphite; \
#  ./bin/logstash-plugin remove logstash-input-imap; \
#  ./bin/logstash-plugin remove logstash-input-twitter; \
#  ./bin/logstash-plugin remove logstash-output-graphite; \
#  ./bin/logstash-plugin remove logstash-output-nagios; \ 
#  ./bin/logstash-plugin remove logstash-output-webhdfs; \
#  ./bin/logstash-plugin remove logstash-codec-graphite
## Install codec and filter plugins
#RUN ./bin/logstash-plugin install \
#	logstash-codec-avro \
#	logstash-codec-es_bulk \
#	logstash-codec-cef \
#	logstash-codec-gzip_lines \
#	logstash-codec-json \
#	logstash-codec-json_lines \
#	logstash-codec-netflow \
#	logstash-codec-nmap \
#	logstash-codec-protobuf \
#	logstash-filter-alter \
#	logstash-filter-bytes \
#	logstash-filter-cidr \
#	logstash-filter-cipher \
#	logstash-filter-clone \
#	logstash-filter-csv \
#	logstash-filter-de_dot \
#	logstash-filter-dissect \
#	logstash-filter-dns \
#	logstash-filter-elasticsearch \
#	logstash-filter-fingerprint \
#	logstash-filter-geoip \
#	logstash-filter-i18n \
#	logstash-filter-json \
#	logstash-filter-json_encode \
#	logstash-filter-kv \
#	logstash-filter-memcached \
#	logstash-filter-metricize \
#	logstash-filter-prune \
#	logstash-filter-translate \
#	logstash-filter-urldecode \
#	logstash-filter-useragent \
#	logstash-filter-xml
## Install integration plugins
#RUN ./bin/logstash-plugin install \
#  logstash-integration-kafka \
#  logstash-integration-rabbitmq \
#  logstash-integration-jdbc
## Install input and output plugins
#RUN ./bin/logstash-plugin install \
#	logstash-input-azure_event_hubs \
#	logstash-input-beats \
#	logstash-input-cloudwatch \
#	logstash-input-elasticsearch \
#	logstash-input-file \
#	logstash-input-lumberjack \
#	logstash-input-google_cloud_storage \
#	logstash-input-google_pubsub \
#	logstash-input-s3-sns-sqs \
#	logstash-input-snmp \
#	logstash-input-snmptrap \
#	logstash-input-syslog \
#	logstash-input-tcp \
#	logstash-input-udp \
#	logstash-input-wmi \
#	logstash-output-cloudwatch \
#	logstash-output-csv \
#	logstash-output-elasticsearch \
#	logstash-output-email \
#	logstash-output-google_bigquery \
#	logstash-output-google_cloud_storage \
#	logstash-output-google_pubsub \
#	logstash-output-lumberjack \
#	logstash-output-nagios \
#	logstash-output-s3 \
#	logstash-output-sns \
#	logstash-output-stdout \
#	logstash-output-syslog \
#	logstash-output-tcp \
#	logstash-output-udp