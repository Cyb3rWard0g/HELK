# HELK [Alpha]

A Hunting ELK (Elasticsearch, Logstash, Kibana) with advanced analytic capabilities.

![alt text](resources/images/HELK_Design.png "HELK Infrastructure")

# Goals

* Provide a free hunting platform to the community and share the basics of Threat Hunting.
* Make sense of a large amount of event logs and add more context to suspicious events during hunting.
* Expedite the time it takes to deploy an ELK stack.
* Improve the testing of hunting use cases in an easier and more affordable way.
* Enable Data Science via Apache Spark, GraphFrames & Jupyter Notebooks.

# Current Status: Alpha

The project is currently in an alpha stage, which means that the code and the functionality are still changing. We haven't yet tested the system with large data sources and in many scenarios. We invite you to try it and welcome any feedback.

# HELK Features

* **Kafka:** A distributed publish-subscribe messaging system that is designed to be fast, scalable, fault-tolerant, and durable.
* **Elasticsearch:** A highly scalable open-source full-text search and analytics engine.
* **Logstash:** A data collection engine with real-time pipelining capabilities.
* **Kibana:** An open source analytics and visualization platform designed to work with Elasticsearch.
* **ES-Hadoop:** An open-source, stand-alone, self-contained, small library that allows Hadoop jobs (whether using Map/Reduce or libraries built upon it such as Hive, Pig or Cascading or new upcoming libraries like Apache Spark ) to interact with Elasticsearch.
* **Spark:** A fast and general-purpose cluster computing system. It provides high-level APIs in Java, Scala, Python and R, and an optimized engine that supports general execution graphs.
* **GraphFrames:** A package for Apache Spark which provides DataFrame-based Graphs.
* **Jupyter Notebook:** An open-source web application that allows you to create and share documents that contain live code, equations, visualizations and narrative text.

# Resources

* [Welcome to HELK! : Enabling Advanced Analytics Capabilities](https://cyberwardog.blogspot.com/2018/04/welcome-to-helk-enabling-advanced_9.html)
* [Spark](https://spark.apache.org/docs/latest/index.html)
* [Spark Standalone Mode](https://spark.apache.org/docs/latest/spark-standalone.html)
* [Setting up a Pentesting.. I mean, a Threat Hunting Lab - Part 5](https://cyberwardog.blogspot.com/2017/02/setting-up-pentesting-i-mean-threat_98.html)
* [An Integrated API for Mixing Graph and Relational Queries](https://cs.stanford.edu/~matei/papers/2016/grades_graphframes.pdf)
* [Graph queries in Spark SQL](https://www.slideshare.net/SparkSummit/graphframes-graph-queries-in-spark-sql)
* [Graphframes Overview](http://graphframes.github.io/index.html)
* [Elastic Producs](https://www.elastic.co/products)
* [Elastic Subscriptions](https://www.elastic.co/subscriptions)
* [Elasticsearch Guide](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
* [spujadas elk-docker](https://github.com/spujadas/elk-docker)
* [deviantony docker-elk](https://github.com/deviantony/docker-elk)

# Getting Started

## WIKI

* [Introduction](https://github.com/Cyb3rWard0g/HELK/wiki)
* [Architecture Overview](https://github.com/Cyb3rWard0g/HELK/wiki/Architecture-Overview)
  * [Kafka](https://github.com/Cyb3rWard0g/HELK/wiki/Kafka)
  * [Logstash](https://github.com/Cyb3rWard0g/HELK/wiki/Logstash)
  * [Elasticsearch](https://github.com/Cyb3rWard0g/HELK/wiki/Elasticsearch)
  * [Kibana](https://github.com/Cyb3rWard0g/HELK/wiki/Kibana)
  * [Spark](https://github.com/Cyb3rWard0g/HELK/wiki/Spark)
* [Installation](https://github.com/Cyb3rWard0g/HELK/wiki/Installation)

## (Docker) Accessing the HELK's Images

By default, the HELK's containers are run in the background (Detached). You can see all your docker containers by running the following command:
```
sudo docker ps

CONTAINER ID        IMAGE                                  COMMAND                  CREATED             STATUS              PORTS                                            NAMES
a97bd895a2b3        cyb3rward0g/helk-spark-worker:2.3.0    "./spark-worker-entr…"   About an hour ago   Up About an hour    0.0.0.0:8082->8082/tcp                           helk-spark-worker2
cbb31f688e0a        cyb3rward0g/helk-spark-worker:2.3.0    "./spark-worker-entr…"   About an hour ago   Up About an hour    0.0.0.0:8081->8081/tcp                           helk-spark-worker
5d58068aa7e3        cyb3rward0g/helk-kafka-broker:1.1.0    "./kafka-entrypoint.…"   About an hour ago   Up About an hour    0.0.0.0:9092->9092/tcp                           helk-kafka-broker
bdb303b09878        cyb3rward0g/helk-kafka-broker:1.1.0    "./kafka-entrypoint.…"   About an hour ago   Up About an hour    0.0.0.0:9093->9093/tcp                           helk-kafka-broker2
7761d1e43d37        cyb3rward0g/helk-nginx:0.0.2           "./nginx-entrypoint.…"   About an hour ago   Up About an hour    0.0.0.0:80->80/tcp                               helk-nginx
ede2a2503030        cyb3rward0g/helk-jupyter:0.32.1        "./jupyter-entrypoin…"   About an hour ago   Up About an hour    0.0.0.0:4040->4040/tcp, 0.0.0.0:8880->8880/tcp   helk-jupyter
ede19510e959        cyb3rward0g/helk-logstash:6.2.4        "/usr/local/bin/dock…"   About an hour ago   Up About an hour    5044/tcp, 9600/tcp                               helk-logstash
e92823b24b2d        cyb3rward0g/helk-spark-master:2.3.0    "./spark-master-entr…"   About an hour ago   Up About an hour    0.0.0.0:7077->7077/tcp, 0.0.0.0:8080->8080/tcp   helk-spark-master
6125921b310d        cyb3rward0g/helk-kibana:6.2.4          "./kibana-entrypoint…"   About an hour ago   Up About an hour    5601/tcp                                         helk-kibana
4321d609ae07        cyb3rward0g/helk-zookeeper:3.4.10      "./zookeeper-entrypo…"   About an hour ago   Up About an hour    2888/tcp, 0.0.0.0:2181->2181/tcp, 3888/tcp       helk-zookeeper
9cbca145fb3e        cyb3rward0g/helk-elasticsearch:6.2.4   "/usr/local/bin/dock…"   About an hour ago   Up About an hour    9200/tcp, 9300/tcp                               helk-elasticsearch
```

Then, you will just have to pick which container you want to access and run the following following commands:
```
sudo docker exec -ti <image-name> bash
root@ede2a2503030:/opt/helk/scripts#
```

# Author

* Roberto Rodriguez [@Cyb3rWard0g](https://twitter.com/Cyb3rWard0g) [@THE_HELK](https://twitter.com/THE_HELK)

# Contributors

* Jose Luis Rodriguez [@Cyb3rPandaH](https://twitter.com/Cyb3rPandaH)
* Robby Winchester [@robwinchester3](https://twitter.com/robwinchester3)
* Jared Atkinson [@jaredatkinson](https://twitter.com/jaredcatkinson)
* Nate Guagenti [@neu5ron](https://twitter.com/neu5ron)
* Jordan Potti [@ok_bye_now](https://twitter.com/ok_bye_now)
* Lee Christensen [@tifkin_](https://twitter.com/tifkin_)

# Contributing

There are a few things that I would like to accomplish with the HELK as shown in the To-Do list below. I would love to make the HELK a stable build for everyone in the community. If you are interested on making this build a more robust one and adding some cool features to it, PLEASE feel free to submit a pull request. #SharingIsCaring

# License: GPL-3.0

[ HELK's GNU General Public License](https://github.com/Cyb3rWard0g/HELK/blob/master/LICENSE)

# TO-Do

- [X] Upload basic Kibana Dashboards
- [X] Integrate Spark & Graphframes
- [X] Add Jupyter Notebook on the top of Spark
- [X] Kafka Integration
- [X] Default X-Pack Basic - Free License Build for ELKStack
- [X] Spark Standalone Cluster Manager integration
- [X] Apache Arrow Integration for Pandas Dataframes
- [ ] Zepplin Notebook Docker option
- [ ] KSQL Client & Server Deployment (Waiting for v5.0)
- [ ] Kubernetes Cluster Migration
- [ ] OSQuery Data Ingestion
- [ ] Create Jupyter Notebooks showing how to use Spark & GraphFrames
- [ ] MITRE ATT&CK mapping to logs or dashboards
- [ ] Cypher for Apache Spark Integration (Might have to switch from Jupyter to Zeppelin Notebook)
- [ ] Somehow integrate neo4j spark connectors with build
- [ ] Nxlog parsers (Logstash Filters)
- [ ] Add more network data sources (i.e Bro)
- [ ] Research & integrate spark structured direct streaming

More coming soon...
