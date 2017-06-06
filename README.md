# HELK [Beta]
The incredible HELK (Hunting, Elasticsearch, Logstash, Kibana) VM. 

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
The HELK can be installed via a bash script or a docker-compose file

### Bash Script
```
git clone https://github.com/Cyb3rWard0g/HELK.git
cd HELK/scripts

[if you want to access your ELK web interface remotely, you have to edit the custom nginx file that comes with the HELK]

sudo nano ../nginx/default
[Replace 127.0.0.1 with your host's IP address]

sudo ./helk_install.sh
```

### Docker-compose
```
git clone https://github.com/Cyb3rWard0g/HELK.git
cd HELK

[if you want to access your ELK web interface remotely, you have to edit the custom kibana.yml file that comes with the HELK]

sudo nano kibana/docker/kibana.yml
[Replace server.host: "localhost" with server.host: "IP ADDRESS"]

sudo docker-compose up
```

## Author
* Roberto Rodriguez [@Cyb3rWard0g](https://twitter.com/Cyb3rWard0g)

## TO-Do
- [ ] Integrate NGINX in the Docker image
- [ ] Upload Kibana Dashboards
- [ ] Add Winlogbeat scripts & files
- [ ] Add/Ingest samples logs to the HELK
- [ ] Install Elastalert
- [ ] Create Elastalert rules

More coming soon...

