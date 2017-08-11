#!/bin/bash

# HELK Dockerfile Start Script (Elasticsearch, Logstash, Kibana & Nginx)
# HELK build version: 0.9 (BETA Script)
# Author: Roberto Rodriguez @Cyb3rWard0g


service logstash start
service elasticsearch start
service kibana restart

sleep 60

service nginx restart

