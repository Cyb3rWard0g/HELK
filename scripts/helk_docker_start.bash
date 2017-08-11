#!/bin/bash

# HELK Dockerfile Start Script (Elasticsearch, Logstash, Kibana & Nginx)
# HELK build version: 0.9 (BETA Script)
# Author: Roberto Rodriguez @Cyb3rWard0g


systemctl daemon-reload
systemctl enable elasticsearch.service
systemctl start elasticsearch.service

sleep 15

systemctl daemon-reload
systemctl enable kibana.service
systemctl start kibana.service

sleep 15

systemctl start logstash
systemctl restart logstash
systemctl enable logstash

sleep 15

systemctl restart nginx