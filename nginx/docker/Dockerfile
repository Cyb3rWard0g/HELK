# Dockerfile for nginx
# Author: Roberto Rodriguez @Cyb3rWard0g

FROM ubuntu:16.04

RUN apt-get update && apt-get -y install nginx && \
    mv /etc/nginx/sites-available/default /etc/nginx/sites-available/backup_default

ADD default /etc/nginx/sites-available/default
ADD htpasswd.users /etc/nginx/htpasswd.users

EXPOSE 80
