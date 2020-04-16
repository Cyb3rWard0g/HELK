# HELK script: HELK Logstash Dockerfile
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# References:
# https://cyberwardog.blogspot.com/2017/02/setting-up-pentesting-i-mean-threat_98.html

FROM docker.elastic.co/logstash/logstash:7.6.2
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for the HELK Logstash."

COPY --chown=logstash:logstash config /usr/share/logstash/config

# Build with plugins baked in
ENV plugins_time_file="/usr/share/logstash/helk-plugins-updated-timestamp.txt"
RUN printf "%s" "$(date +"%Y-%m-%d %T")" > "${plugins_time_file}"
RUN chown logstash:logstash "${plugins_time_file}"

COPY --chown=logstash:logstash plugins/helk-offline-logstash-codec_and_filter_plugins.zip /usr/share/logstash/plugins/helk-offline-logstash-codec_and_filter_plugins.zip
COPY --chown=logstash:logstash plugins/helk-offline-logstash-input-plugins.zip /usr/share/logstash/plugins/helk-offline-logstash-input-plugins.zip
COPY --chown=logstash:logstash plugins/helk-offline-logstash-output-plugins.zip /usr/share/logstash/plugins/helk-offline-logstash-output-plugins.zip
RUN logstash-plugin update \
    && logstash-plugin install file:///usr/share/logstash/plugins/helk-offline-logstash-codec_and_filter_plugins.zip \
    && logstash-plugin install file:///usr/share/logstash/plugins/helk-offline-logstash-input-plugins.zip \
    && logstash-plugin install file:///usr/share/logstash/plugins/helk-offline-logstash-output-plugins.zip \
    && rm -f /usr/share/logstash/pipeline/logstash.conf