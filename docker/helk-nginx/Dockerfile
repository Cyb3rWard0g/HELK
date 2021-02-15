# HELK script: HELK Nginx Dockerfile
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# References: 
# https://hub.docker.com/_/nginx
# https://github.com/nginxinc/docker-nginx

FROM nginx:stable
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
COPY scripts/40-create-jupyter-certificate.sh /docker-entrypoint.d/
RUN chmod +x /docker-entrypoint.d/40-create-jupyter-certificate.sh