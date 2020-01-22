# HELK script: HELK Logstash Dockerfile
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# References:
# https://cyberwardog.blogspot.com/2017/02/setting-up-pentesting-i-mean-threat_98.html

FROM docker.elastic.co/logstash/logstash:7.5.2
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for the HELK Logstash."

RUN rm -f /usr/share/logstash/pipeline/logstash.conf

# Build with plugins baked in
ENV plugins_time_file="/usr/share/logstash/helk-plugins-updated-timestamp.txt"
RUN printf "%s" "$(date +"%Y-%m-%d %T")" > "${plugins_time_file}"
RUN chown logstash:logstash "${plugins_time_file}"
#RUN echo"$(date +"%Y-%m-%d %T")" > "${plugins_time_file}"
COPY --chown=logstash:logstash plugins/helk-offline-logstash-codec_and_filter_plugins.zip /usr/share/logstash/plugins/helk-offline-logstash-codec_and_filter_plugins.zip
COPY --chown=logstash:logstash plugins/helk-offline-logstash-input_and_output-plugins.zip /usr/share/logstash/plugins/helk-offline-logstash-input_and_output-plugins.zip
RUN logstash-plugin update
RUN logstash-plugin install file:///usr/share/logstash/plugins/helk-offline-logstash-codec_and_filter_plugins.zip
RUN logstash-plugin install file:///usr/share/logstash/plugins/helk-offline-logstash-input_and_output-plugins.zip
RUN rm /usr/share/logstash/plugins/helk-offline-logstash-codec_and_filter_plugins.zip
RUN rm /usr/share/logstash/plugins/helk-offline-logstash-input_and_output-plugins.zip