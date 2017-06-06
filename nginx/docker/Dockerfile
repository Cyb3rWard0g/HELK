# Dockerfile for nginx
# Author: Roberto Rodriguez @Cyb3rWard0g

FROM debian:jessie

RUN apt-get update && apt-get -y install nginx && \
	echo "helkadmin:`openssl passwd -apr1 hunting`" | tee -a /etc/nginx/htpasswd.users && \
	mv /etc/nginx/sites-available/default /etc/nginx/sites-available/backup_default

ADD default /etc/nginx/sites-available/default

EXPOSE 80

CMD ["/bin/systemctl", "restart", "nginx"]