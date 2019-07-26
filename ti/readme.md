# Download and configuration file for integrating OTX Data with HELK

## Installing OTX python module and Download TI feeds
Install OTX python module with ` pip install OTXv2 ` (in your local server, not in docker). For more information please go, https://github.com/AlienVault-OTX/OTX-Python-SDK.

Place helkOTX.py to /HELK/docker/helk-logstash/enrichments/cti/ folder.(in your local server, not in docker)

Run helkOTX.py with ` python helkOTX.py `.

After running the python script, you will find these CSV files. 
* otx_domain_.csv  
* otx_ipv4_.csv  
* otx_md5_.csv  
* otx_sha1_.csv  
* otx_sha256_.csv

## Configuring SYSMON logstash file 

Replace ` 1531-winevent-sysmon-filter.conf ` in ` /HELK/docker/helk-logstash/pipeline/ ` folder.

After replacing ` 1531-winevent-sysmon-filter.conf ` file restart the helk-logstash with ` docker restart helk-logstash `. 
Then refresh the index fields in Kibana ` (Management -> Index pattern -> refresh)` . 
