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
sudo ./helk_install.sh

```
Once the installation completes, your ELK Stack Web interface will be available ONLY locally (127.0.0.1). Edit your /etc/nginx/sites-available/default file to give it an IP address:
```

sudo nano /etc/nginx/sites-available/default
[Replace 127.0.0.1 with your host's IP address]

sudo systemctl restart nginx

```

### Docker-compose
```
git clone https://github.com/Cyb3rWard0g/HELK.git
cd HELK
sudo docker-compose up

```

## Author
* Roberto Rodriguez [@Cyb3rWard0g](https://twitter.com/Cyb3rWard0g)


More coming soon...

