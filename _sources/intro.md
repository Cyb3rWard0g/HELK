# Introduction

[![](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![](https://img.shields.io/twitter/follow/THE_HELK.svg?style=social&label=Follow)](https://twitter.com/THE_HELK)
[![](https://img.shields.io/github/issues-closed/Cyb3rward0g/HELK.svg)](https://GitHub.com/Cyb3rWard0g/HELK/issues?q=is%3Aissue+is%3Aclosed)
[![](https://badges.frapsoft.com/os/v3/open-source.svg?v=103)](https://github.com/ellerbrock/open-source-badges/)

![](images/HELK-Design.png)

The Hunting ELK or simply the HELK is one of the first open source hunt platforms with advanced analytics capabilities such as SQL declarative language, graphing, structured streaming, and even machine learning via Jupyter notebooks and Apache Spark over an ELK stack. This project was developed primarily for research, but due to its flexible design and core components, it can be deployed in larger environments with the right configurations and scalable infrastructure.

## Goals

* Provide an open source hunting platform to the community and share the basics of Threat Hunting.
* Expedite the time it takes to deploy a hunt platform.
* Improve the testing and development of hunting use cases in an easier and more affordable way.
* Enable Data Science capabilities while analyzing data via Apache Spark, GraphFrames & Jupyter Notebooks.

## Main Features

* **Kafka**: A distributed publish-subscribe messaging system that is designed to be fast, scalable, fault-tolerant, and durable.
* **Elasticsearch**: A highly scalable open-source full-text search and analytics engine.
* **Logstash**: A data collection engine with real-time pipelining capabilities.
* **Kibana**: An open source analytics and visualization platform designed to work with Elasticsearch.
* **ES-Hadoop**: An open-source, stand-alone, self-contained, small library that allows Hadoop jobs (whether using Map/Reduce or libraries built upon it such as Hive, Pig or Cascading or new upcoming libraries like Apache Spark ) to interact with Elasticsearch.
* **Spark**: A fast and general-purpose cluster computing system. It provides high-level APIs in Java, Scala, Python and R, and an optimized engine that supports general execution graphs.
* **Jupyter Notebooks**: An open-source web application that allows you to create and share documents that contain live code, equations, visualizations and narrative text.

## Optional Features

* **KSQL**: Confluent KSQL is the open source, streaming SQL engine that enables real-time data processing against Apache Kafka®. It provides an easy-to-use, yet powerful interactive SQL interface for stream processing on Kafka, without the need to write code in a programming language such as Java or Python
* **Elastalert**: ElastAlert is a simple framework for alerting on anomalies, spikes, or other patterns of interest from data in Elasticsearch
* **Sigma**: Sigma is a generic and open signature format that allows you to describe relevant log events in a straightforward manner.

## Author

* Roberto Rodriguez [@Cyb3rWard0g](https://twitter.com/Cyb3rWard0g) [@THE_HELK](https://twitter.com/THE_HELK)

## Current Committers

* Nate Guagenti [@neu5ron](https://twitter.com/neu5ron)

## Contributing

There are a few things that I would like to accomplish with the HELK as shown in the To-Do list below. I would love to make the HELK a stable build for everyone in the community. If you are interested on making this build a more robust one and adding some cool features to it, PLEASE feel free to submit a pull request. #SharingIsCaring

# TO-Do

- [ ] Kubernetes Cluster Migration
- [ ] OSQuery Data Ingestion
- [ ] MITRE ATT&CK mapping to logs or dashboards
- [ ] Cypher for Apache Spark Integration (Adding option for Zeppelin Notebook)
- [ ] Test and integrate neo4j spark connectors with build
- [ ] Add more network data sources (i.e Bro)
- [ ] Research & integrate spark structured direct streaming
- [ ] Packer Images
- [ ] Terraform integration (AWS, Azure, GC)
- [ ] Add more Jupyter Notebooks to teach the basics
- [ ] Auditd beat intergation

## License: GPL-3.0

[ HELK's GNU General Public License](https://github.com/Cyb3rWard0g/HELK/blob/master/LICENSE)