#!/bin/bash

# HELK Installation Script (Elasticsearch, Logstash, Kibana & Nginx)
# HELK build version: 0.9 (BETA Script)
# Author: Roberto Rodriguez @Cyb3rWard0g

# Description: This script installs every single component of the ELK Stack plus Nginx
# ELK version: 5x
# Blog: https://cyberwardog.blogspot.com/2017/02/setting-up-pentesting-i-mean-threat_98.html

echo "[HELK INFO] Installing updates.."
apt-get update


echo "[HELK INFO] Installing openjdk-8-jre-headless.."
apt-get install -y openjdk-8-jre-headless


# Elastic signs all of their packages with their own Elastic PGP signing key.
echo "[HELK INFO] Downloading and installing (writing to a file) the public signing key to the host.."
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -


# Before installing elasticsearch, we have to set the elastic packages definitions to our source list.
# For this step, elastic recommends to have "apt-transport-https" installed already or install it before adding the elasticsearch apt repository source list definition to your /etc/apt/sources.list
echo "Installing apt-transport-https.."
apt-get install apt-transport-https


echo "[HELK INFO] Adding elastic packages source list definitions to your sources list.."
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list


echo "[HELK INFO] Installing updates.."
apt-get update


# *********** Installing Elasticsearch ***************
echo "[HELK INFO] Installing Elasticsearch.."
apt-get install elasticsearch

echo "[HELK INFO] Creating a backup of Elasticsearch's original yml file.."
mv /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/backup_elasticsearch.yml

echo "[HELK INFO] copying custom elasticsearch.yml file to /etc/elasticsearch/.."
cp -v ../elasticsearch/elasticsearch.yml /etc/elasticsearch/

echo "[HELK INFO] Starting elasticsearch and setting elasticsearch to start automatically when the system boots.."
systemctl daemon-reload
systemctl enable elasticsearch.service
systemctl start elasticsearch.service


echo "[HELK INFO] Installing updates.."
apt-get update


# *********** Installing Kibana ***************
echo "[HELK INFO] Installing Kibana.."
apt-get install kibana

echo "[HELK INFO] Creating a backup of Kibana's original yml file.."
mv /etc/kibana/kibana.yml /etc/kibana/backup_kibana.yml

echo "[HELK INFO] copying custom kibana.yml file to /etc/kibana/.."
cp -v ../kibana/kibana.yml /etc/kibana/

echo "[HELK INFO] Starting kibana and setting kibana to start automatically when the system boots.."
systemctl daemon-reload
systemctl enable kibana.service
systemctl start kibana.service


# *********** Installing Nginx ***************
echo "[HELK INFO] Installing Nginx.."
apt-get -y install nginx

echo "[HELK INFO] Creating an admin user to Kibana.."
echo "[HELK INFO] Naming the admin user helkadmin.."
echo "helkadmin:`openssl passwd -apr1`" | sudo tee -a /etc/nginx/htpasswd.users

echo "[HELK INFO] Creating a backup of Nginx's config file.."
mv /etc/nginx/sites-available/default /etc/nginx/sites-available/backup_default

echo "[HELK INFO] copying custom nginx config file to /etc/nginx/sites-available/.."
cp -v ../nginx/default /etc/nginx/sites-available/

echo "[HELK INFO] testing nginx configuration.."
nginx -t

echo "[HELK INFO] Restarting nginx service.."
systemctl restart nginx


echo "[HELK INFO] Installing updates.."
apt-get update


# *********** Installing Logstash ***************
echo "[HELK INFO] Installing Logstash.."
apt-get install logstash

echo "[HELK INFO] Copying logstash's .conf files.."
cp -v ../logstash/02-beats-input.conf /etc/logstash/conf.d/
cp -v ../logstash/50-elasticsearch-output.conf /etc/logstash/conf.d/

echo "[HELK INFO] Starting logstash and setting Logstash to start automatically when the system boots.."
systemctl start logstash
systemctl restart logstash
systemctl enable logstash


echo "[HELK INFO] Your HELK has been succesfully installed.."
echo "[HELK INFO] Your HELK can be accessed ONLY locally by default. PLEASE run the following to give it an IP address and be able to access it from a different computer:"
echo "[HELK INFO] sudo nano /etc/nginx/sites-available/default"
echo "[HELK INFO] replace 127.0.0.1 with your host's IP address"
echo "[HELK INFO] finally run the following:"
echo "[HELK INFO] sudo systemctl restart nginx"
echo "[HELK INFO] Browse to the IP address from a different computer and enter the credentials for helkadmin"
