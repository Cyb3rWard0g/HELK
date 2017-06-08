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

## Author
* Roberto Rodriguez [@Cyb3rWard0g](https://twitter.com/Cyb3rWard0g)

## TO-Do
- [X] Integrate NGINX in the Docker image
- [ ] Upload Kibana Dashboards
- [ ] Add Winlogbeat scripts & files
- [ ] Add/Ingest samples logs to the HELK
- [ ] Install Elastalert
- [ ] Create Elastalert rules

More coming soon...

