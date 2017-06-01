#!/bin/bash

# HELK Start HELK Services (Elasticsearch, Logstash, Kibana & Nginx)
# HELK build version: 0.9 (BETA Script)
# Author: Roberto Rodriguez @Cyb3rWard0g

# Description: This script starts elasticsearch, Logstash, Kibana and Nginx after the creationg of the image

systemctl start elasticsearch
systemctl restart kibana
systemctl restart logstash
systemctl restart nginx

