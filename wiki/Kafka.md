# Design
[[https://github.com/Cyb3rWard0g/HELK/raw/master/resources/images/KAFKA-Design.png]]

# Kafka Ecosystem
## Producers
Producers publish data to the topics of their choice. The producer is responsible for choosing which record to assign to which partition within the topic.

HELK currently accepts data sent to a few topics such as `winlogbeat` for Windows systems and `filebeat` for Linux or OSX systems. From a Windows perspective, it is common to have **Winlogbeat** (Log Shipper/Producer) installed on all the endpoints. However, it is recommended to use solutions such as [Windows Event Forwarding (WEF)](https://docs.microsoft.com/en-us/windows/security/threat-protection/use-windows-event-forwarding-to-assist-in-intrusion-detection) servers to collect and centralize your logs, and then have Winlogbeat or NXlog installed on them to ship the logs to your HELK Kafka broker.

When using **Winlogbeat** you can use the following config:
```
winlogbeat.event_logs:
  - name: Application
    ignore_older: 30m
  - name: Security
    ignore_older: 30m
  - name: System
    ignore_older: 30m
  - name: Microsoft-windows-sysmon/operational
    ignore_older: 30m
  - name: Microsoft-windows-PowerShell/Operational
    ignore_older: 30m
    event_id: 4103, 4104
  - name: Windows PowerShell
    event_id: 400,600
    ignore_older: 30m
  - name: Microsoft-Windows-WMI-Activity/Operational
    event_id: 5857,5858,5859,5860,5861

output.kafka:
  hosts: ["<HELK-IP>:9092"]
  topic: "winlogbeat"
  max_retries: 2
  max_message_bytes: 1000000
```
You can check the how-to section in this wiki to learn how to check if your winlogbeat log shipper is sending data to a Kafka broker.

## Kafka Broker
HELK uses a kafka cluster conformed of 1 broker (Not really a cluster, but it is a good start to host it in a lab environment). If you add more brokers to the cluster, each broker would have it's own ID number and topic log partitions. Connecting to one broker bootstraps a client to the entire Kafka cluster.

The HELK broker has its own `server.properties` file. You can find it [here](https://github.com/Cyb3rWard0g/HELK/blob/master/docker/helk-kafka-broker/server.properties). Some of the basic settings that you need to understand are the following:

| Name | Description | Type | Value |
|--------|---------|-------|-------|
| broker.id | The broker id for this server. If unset, a unique broker id will be generated. To avoid conflicts between zookeeper generated broker id's and user configured broker id's, generated broker ids start from reserved.broker.max.id + 1. | int | 1 |
| listeners | Listener List - Comma-separated list of URIs we will listen on and the listener names. Specify hostname as 0.0.0.0 to bind to all interfaces. For the docker deployment, it is set to the kafka broker container name and used to communicate with other containers inside of the docker environment ONLY | string | PLAINTEXT://helk-kafka-broker:9092 |
| advertised.listeners | Listeners to publish to ZooKeeper for clients to use, if different than the `listeners` config property. In IaaS environments, this may need to be different from the interface to which the broker binds. For the docker deployment, this is the IP address of the machine hosting your docker containers. This will be ip address that your producers can talk to from outside of the docker environment. When Broker starts, the current value is updated automatically by the environment variable ADVERTISED_LISTENER | string | PLAINTEXT://HELKIP:9092 |
| log.dirs | The directories in which the log data is kept. If not set, the value in log.dir is used | string | /tmp/kafka-logs |
| auto.create.topics.enable | Enable auto creation of topic on the server. This is disabled in HELK to avoid any producers creating new topics | boolean | false |
| log.retention.hours | The minimum age of a log file to be eligible for deletion due to age | int | 4 |

## Zookeeper
Kafka needs ZooKeeper to work efficiently in the cluster. Kafka uses Zookeeper to do leadership election of Kafka Broker and Topic Partition pairs. Kafka uses Zookeeper to manage service discovery for Kafka Brokers that form the cluster. Zookeeper sends changes of the topology to Kafka, so each node in the cluster knows when a new broker joined, a Broker died, a topic was removed or a topic was added, etc. Zookeeper provides an in-sync view of Kafka Cluster configuration.

## HELK Kafka Topics
Kafka automatically creates 3 topics:

| topic | Description | 
|--------|---------|
| winlogbeat | Main topic that stores raw event log data sent from endpoints with winlogbeat installed. |
| SYSMON_JOIN | Topic that stores Windows Sysmon events that have been enriched by KSQL commands to join **ProcessCreate** (event 1) and **NetworkConnect** (event 3) by their `ProcessGUID` values. |
| winsysmon | Topic used for Logstash to send transformed/parsed Windows Sysmon event data back.  |
| winsecurity | topic used for Logstash to send transformed/parsed Windows security event data back. |
| filebeat | Topic that stores OSQuery data |

# How-To
* [Check Kafka topic ingestion](https://github.com/Cyb3rWard0g/HELK/wiki/Check-Kafka-topic-ingestion)
* [Check Winlogbeat shipping](https://github.com/Cyb3rWard0g/HELK/wiki/Check-Winlogbeat-shipping)
* [Update Kafka Broker IP](https://github.com/Cyb3rWard0g/HELK/wiki/Update-Kafka-Broker-IP)

# References
* [Kafka Producer API](http://kafka.apache.org/documentation.html#producerapi)
* [Kafka Architecture](http://cloudurable.com/blog/kafka-architecture/index.html)