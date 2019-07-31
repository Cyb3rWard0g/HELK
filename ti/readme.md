
# Configuration file for integrating OTX Data with HELK 

## Install OTX python module and Download TI feeds
Install OTX python module with ` pip install OTXv2 ` (in your local server, not in docker). For more information please go, https://github.com/AlienVault-OTX/OTX-Python-SDK.

Place helkOTX.py to /HELK/docker/helk-logstash/enrichments/cti/ folder.(in your local server, not in docker). Since HELK already mounted with your local system on helk-logstash/enrichments/cti folder.

Run helkOTX.py with ` python helkOTX.py `.

After running the python script, you will find these CSV files. 
* otx_domain_.csv  
* otx_ipv4_.csv  
* otx_md5_.csv  
* otx_sha1_.csv  
* otx_sha256_.csv

## Install pandas

` pip install pandas `

## Configuring SYSMON logstash file 

Replace ` 1531-winevent-sysmon-filter.conf ` in ` /HELK/docker/helk-logstash/pipeline/ ` folder.

After replacing ` 1531-winevent-sysmon-filter.conf ` file restart the helk-logstash with ` docker restart helk-logstash `. 
Then refresh the index fields in Kibana ` (Management -> Index pattern -> refresh)` . 

Then browse some ips or domains which is included in ` otx_domain_.csv and otx_ipv4_.csv  ` file. After that you can search using `  ti.DestinationIP.otx:* or  ti.Domain.otx:* ` . 

## Configuration Details


To fetch destination IP that is event id 3 with Alienvault OTX, TI feeds. 
```
      translate {
     field => "[dst_ip_addr]"
      destination => "[ti][DestinationIP][otx]"
      dictionary_path => '/usr/share/logstash/cti/AlientVault/OTX-Python-SDK/HELK_IOC/otx_ipv4_.csv'
     }
```
To fetch destination domain that is event id 22 with Alienvault OTX, TI feeds.

```
   if [dns_query_name] { 
     translate {
          field => "[dns_query_name]"
          destination => "[ti][Domain][otx]"
          dictionary_path => '/usr/share/logstash/cti/AlientVault/OTX-Python-SDK/test/otx_domain_.csv' 
         }
   }
   
```

To fetch file checksum(SHA256)  with Alienvault OTX, TI feeds.

```

   if [hash_sha256] {
     translate {
	  field => "[hash_sha256]"
	  destination => "[ti][SHA256][otx]"
	  dictionary_path => '/usr/share/logstash/cti/AlientVault/OTX-Python-SDK/HELK_IOC/otx_sha256_.csv' 
	 }
```

To fetch file checksum(MD5)  with Alienvault OTX, TI feeds.

```

   if [hash_md5] {
translate {
          field => "[hash_md5]"
          destination => "[ti][MD5][otx]"
          dictionary_path => '/usr/share/logstash/cti/AlientVault/OTX-Python-SDK/HELK_IOC/otx_md5_.csv' 
         }

}

```

# Get domain registration (Event id 22) for more detection 

Python script credit to @markbaggett.

Clone domain status script from ` https://github.com/MarkBaggett/domain_stats `. Then run the server with `  python domain_stats.py -ip localip port `. Note: You need to keep it running.

Then change your logstash config file that is ` 1531-winevent-sysmon-filter.conf `. 

```
    if [event_id] == 22 {
      mutate {
        add_field => { "action" => "dnsquery" }
        rename => {
          "QueryName" => "dns_query_name"
          "QueryStatus" => "dns_query_status"
          "QueryResults" => "dns_query_results"
        }
      }
          rest {
      request => {
        url => "http://serverhost:port/domain/creation_date/%{[dns_query_name]}"
        method => "get"
      }
      #sprintf => true
      json => false
      target => "[enrich][whois][DNS]"
    }
    }

``` . 

After that restart your logstash. You will see ` enrich.whois.DNS ` field in Kibana. Don't forget to refresh your index.

![GitHub Logo](/image/dns.png)
