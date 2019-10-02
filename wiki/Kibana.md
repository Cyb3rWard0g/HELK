# Design
[[https://github.com/Cyb3rWard0g/HELK/raw/master/resources/images/KIBANA-Design.png]]

# Visualize your logs
## Discover
Make sure you have logs being sent to your HELK first (At least Windows security and Sysmon events). Then, go to http://<HELK's IP> in your preferred browser. If you dont have logs being sent to your HELK pipe (Kafka) or just starting to get processed by Kafka and Logstash, you might get the message "
No matching indices found: No indices match pattern "logs-endpoint-winevent-sysmon-*"** 

[[https://github.com/Cyb3rWard0g/HELK/raw/master/resources/images/KIBANA-NoIndicesPattern.png]]

That is normal at the beginning. Refresh your screen a couple of times in order to start visualizing your logs.

Currently, HELK creates automatically 7 index patterns for you and sets **logs-endpoint-winevent-sysmon-*** as your default one:
* "logs-*"
* "logs-endpoint-winevent-sysmon-*"
* "logs-endpoint-winevent-security-*"
* "logs-endpoint-winevent-application-*"
* "logs-endpoint-winevent-system-*"
* "logs-endpoint-winevent-powershell-*"
* "logs-endpoint-winevent-wmiactivity-*"

[[https://github.com/Cyb3rWard0g/HELK/raw/master/resources/images/KIBANA-Discovery.png]]

# Dashboards
Currently, the HELK comes with 3 dashboards:

## Global_Dashboard

[[https://github.com/Cyb3rWard0g/HELK/raw/master/resources/images/KIBANA-GlobalDashboard.png]]

## Network_Dashboard

[[https://github.com/Cyb3rWard0g/HELK/raw/master/resources/images/KIBANA-NetworkDashboard.png]]

## Sysmon_Dashboard

[[https://github.com/Cyb3rWard0g/HELK/raw/master/resources/images/KIBANA-SysmonDashboard.png]]

# Monitoring Views (x-Pack Basic Free License)

## Kibana Initial Overview

[[https://github.com/Cyb3rWard0g/HELK/raw/master/resources/images/MONITORING-Kibana-Overview.png]]

## Elasticsearch Overview

[[https://github.com/Cyb3rWard0g/HELK/raw/master/resources/images/MONITORING-Elasticsearch-Overview.png]]

## Logstash Overview

[[https://github.com/Cyb3rWard0g/HELK/raw/master/resources/images/MONITORING-Logstash-Overview.png]]

[[https://github.com/Cyb3rWard0g/HELK/raw/master/resources/images/MONITORING-Logstash-Nodes-Overview.png]]


