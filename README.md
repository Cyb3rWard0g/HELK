# HELK [Beta]
The incredible HELK (Hunting, Elasticsearch, Logstash, Kibana) VM. 

# Getting Started
For now, this basic build can be installed with the help of a bash script. This script is based on most of the commands I used and described [HERE](https://cyberwardog.blogspot.com/2017/02/setting-up-pentesting-i-mean-threat_98.html) 

### Requirements
* OS: Ubuntu-16.04.2 Server amd64 (Tested)
* Network Connection: NAT or Bridge
* RAM: 4GB (minimum)

### Installation
* Run `sudo su -`
* Run `git clone https://github.com/Cyb3rWard0g/HELK.git`
* Run `cd HELK/scripts`
* Run `chmod +x helk_install.sh`
* Run `./helk_install.sh`

### Custom Configuration
Once the installation completes, your ELK Stack Web interface will ONLY be accessed locally (127.0.0.1). Edit your /etc/nginx/sites-available/default file doing the following:
* Run `sudo nano /etc/nginx/sites-available/default`
* Replace 127.0.0.1 with your host's IP address
* Run `sudo systemctl restart nginx`

More coming soon...

