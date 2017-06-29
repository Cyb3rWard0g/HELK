# HELK [Beta]
The incredible HELK (Hunting, Elasticsearch, Logstash, Kibana) VM.

# Goals
* Provide a free hunting platform to the community and share the basics of Threat Hunting.
* Make sense of a large amount of event logs and add more context to suspicious events during hunting.
* Expedite the time it takes to deploy an ELK stack.
* Improve the testing of hunting use cases in an easier and more affordable way. 

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
	* Docker & Docker-compose (Needed for HELK Docker Installation ONLY)

### Installing Docker & Docker-compose
If you decide to build,(re)create, start and attach the specific containters needed for the HELK services (Elasticsearch, Logstash & Kibana), you will have to install Docker and Docker-compose first.

```
git clone https://github.com/Cyb3rWard0g/HELK.git
cd HELK/scripts
sudo ./helk_docker_install.sh
```
 
## HELK Installation
The HELK can be installed via a bash script or a docker-compose file. After installing the HELK, browse to your HELK (host) IP address and log on with username:helk & password:hunting.

### Bash Script
```
sudo git clone https://github.com/Cyb3rWard0g/HELK.git
cd HELK/scripts
sudo ./helk_install.sh
```

### Docker-compose
```
sudo git clone https://github.com/Cyb3rWard0g/HELK.git
cd HELK
sudo docker-compose up
```

# Author
* Roberto Rodriguez [@Cyb3rWard0g](https://twitter.com/Cyb3rWard0g)

# Contributors

# Contributing
There are a few things that I would like to accomplish with the HELK as shown in the To-Do list below, but I would also woult love to make the HELK a stable build for everyone in the community. If you are interested on making this build a more robust one and adding some cool features to it, PLEASE feel free to submit a pull request. #SharingIsCaring 

# TO-Do
- [X] Integrate NGINX in the Docker image
- [ ] Upload Kibana Dashboards
- [ ] Add Winlogbeat scripts & files
- [ ] Add/Ingest samples logs to the HELK
- [ ] Install Elastalert
- [ ] Create Elastalert rules

More coming soon...

