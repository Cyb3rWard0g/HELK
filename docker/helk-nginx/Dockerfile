# HELK script: HELK Nginx Dockerfile
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# References: 
# https://cyberwardog.blogspot.com/2017/02/setting-up-pentesting-i-mean-threat_98.html
# https://github.com/spujadas/elk-docker/blob/master/Dockerfile

FROM nginx:1.17.9
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for the HELK Nginx."

ENV DEBIAN_FRONTEND noninteractive

# *********** Installing Prerequisites ***************
# -qq : No output except for errors
RUN echo "[HELK-DOCKER-INSTALLATION-INFO] Updating Ubuntu base image.." \
  && apt-get update -qq
RUN apt-get install -qqy curl
RUN apt-get -qy clean \
  autoremove

# *********** Adding HELK scripts and files to Container ***************
COPY scripts/nginx-entrypoint.sh /opt/helk/scripts/
RUN chmod +x /opt/helk/scripts/nginx-entrypoint.sh

# *********** RUN HELK ***************
EXPOSE 80 443
WORKDIR "/opt/helk/scripts/"
ENTRYPOINT ["./nginx-entrypoint.sh"]