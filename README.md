# HELK [Beta]
A Hunting ELK (Elasticsearch, Logstash, Kibana) with advanced analytic capabilities.
![alt text](resources/images/HELK_Stack.png "HELK Infrastructure")

# Goals
* Provide a free hunting platform to the community and share the basics of Threat Hunting.
* Make sense of a large amount of event logs and add more context to suspicious events during hunting.
* Expedite the time it takes to deploy an ELK stack.
* Improve the testing of hunting use cases in an easier and more affordable way.
* Learn Data Science via Apache Spark, GraphFrames & Jupyter Notebooks.

# Resources
* [Setting up a Pentesting.. I mean, a Threat Hunting Lab - Part 5](https://cyberwardog.blogspot.com/2017/02/setting-up-pentesting-i-mean-threat_98.html)
* [Elastic Producs](https://www.elastic.co/products)
* [docker-elk](https://github.com/deviantony/docker-elk)

# Getting Started

## Requirements
* OS: Ubuntu-16.04.2 Server amd64 (Tested)
* Network Connection: NAT or Bridge
* RAM: 4GB (minimum)
* Applications:
	* Docker(Needed for HELK Docker Installation ONLY)

## Pulling from DockerHub
You can pull a Docker Image from my DockerHub. You will need to install Docker first:

```
git clone https://github.com/Cyb3rWard0g/HELK.git
cd HELK/scripts
sudo ./helk_docker_install.sh
```
```
sudo docker pull cyb3rward0g/helk
sudo docker run -d -p 80:80 -p 5044:5044 -p 8880:8880 -p 4040:4040 cyb3rward0g/helk
```
Access your Docker Image by first getting the Container ID and then running Docker exec:
```
sudo docker ps
sudo docker exec -ti 23669faeafb0  bash
```
You can then browse to your host's IP and provide the default HELK credentials (helk:hunting)

## Installing from source via Docker
You can also run the DockerFile and create your own image locally.

```
git clone https://github.com/Cyb3rWard0g/HELK.git
cd HELK/
sudo ./helk_docker_start.sh
```

## Installing from source via bash script

```
git clone https://github.com/Cyb3rWard0g/HELK.git
cd HELK/scripts
sudo ./helk_install.sh
```

## HELK Settings
HELK will by default create a docker named volume `helk_esdata` which will persist your elasticsearch data between containers. If HELK will be used in higher resource environments, `ES_JAVA_OPTS: "-Xmx256m -Xms256m"` can be modified, however do not allocate more than 50% of available memory. After installing the HELK, browse to your HELK (host) IP address and log on with 

* username: helk 
* password: hunting

# Author
* Roberto Rodriguez [@Cyb3rWard0g](https://twitter.com/Cyb3rWard0g)

# Contributors
* Robby Winchester [@robwinchester3](https://twitter.com/robwinchester3)

# Contributing
There are a few things that I would like to accomplish with the HELK as shown in the To-Do list below, but I would also woult love to make the HELK a stable build for everyone in the community. If you are interested on making this build a more robust one and adding some cool features to it, PLEASE feel free to submit a pull request. #SharingIsCaring 

# TO-Do
- [X] Integrate NGINX in the Docker image
- [X] Upload Kibana Dashboards
- [X] Add Winlogbeat scripts & files
- [ ] Install Elastalert
- [ ] Create Elastalert rules
- [ ] Create Jupyter Notebooks showing how to use Spark & GraphFrames

More coming soon...

