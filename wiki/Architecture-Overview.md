# Design
[[https://github.com/Cyb3rWard0g/HELK/raw/master/resources/images/HELK_Design.png]]

The HELK follows the native flow of an ELK stack with events being sent (preferably from Winlogbeat for now) to Kafka brokers. Next, they get filtered by Logstash and sent over to an Elasticsearch database. Then, they can be visualized in a Kibana instance. However, what sets the HELK apart from other ELK builds is the extra analytic capabilities provided by Apache Spark, GraphFrames and Jupyter. More soon....

# Core Components Definitions
## Kafka
"Kafka is a distributed publish-subscribe messaging system used for building real-time data pipelines and streaming apps. It is horizontally scalable, fault-tolerant, wicked fast, and runs in production in thousands of companies." [Kafka](https://kafka.apache.org/)

## Elasticsearch
"Elasticsearch is a highly scalable open-source full-text search and analytics engine. It allows you to store, search, and analyze big volumes of data quickly and in near real time. It is generally used as the underlying engine/technology that powers applications that have complex search features and requirements." [Elastic Reference](https://www.elastic.co/guide/en/elasticsearch/reference/current/getting-started.html)

## Logstash
"Logstash is an open source data collection engine with real-time pipelining capabilities. Logstash can dynamically unify data from disparate sources and normalize the data into destinations of your choice. Cleanse and democratize all your data for diverse advanced downstream analytics and visualization use cases.
 [Elastic Reference](https://www.elastic.co/guide/en/logstash/current/introduction.html)

## Kibana
"Kibana is an open source analytics and visualization platform designed to work with Elasticsearch. You use Kibana to search, view, and interact with data stored in Elasticsearch indices. You can easily perform advanced data analysis and visualize your data in a variety of charts, tables, and maps.
Kibana makes it easy to understand large volumes of data. Its simple, browser-based interface enables you to quickly create and share dynamic dashboards that display changes to Elasticsearch queries in real time." [Elastic Reference](https://www.elastic.co/guide/en/kibana/current/introduction.html)

## ES-Hadoop
"Elasticsearch for Apache Hadoop is an open-source, stand-alone, self-contained, small library that allows Hadoop jobs (whether using Map/Reduce or libraries built upon it such as Hive, Pig or Cascading or new upcoming libraries like Apache Spark ) to interact with Elasticsearch. One can think of it as a connector that allows data to flow bi-directionaly so that applications can leverage transparently the Elasticsearch engine capabilities to significantly enrich their capabilities and increase the performance." [Elastic Reference](https://www.elastic.co/guide/en/elasticsearch/hadoop/current/reference.html)

## Apache Spark
"Apache Spark is a fast and general-purpose cluster computing system. It provides high-level APIs in Java, Scala, Python and R, and an optimized engine that supports general execution graphs. It also supports a rich set of higher-level tools including Spark SQL for SQL and structured data processing, MLlib for machine learning, GraphX for graph processing, and Spark Streaming." [Apache Spark Reference](https://spark.apache.org/docs/latest/)

## GraphFrames
"GraphFrames is a package for Apache Spark which provides DataFrame-based Graphs. It provides high-level APIs in Scala, Java, and Python. It aims to provide both the functionality of GraphX and extended functionality taking advantage of Spark DataFrames. This extended functionality includes motif finding, DataFrame-based serialization, and highly expressive graph queries." [Graphframes Reference](https://graphframes.github.io/)

## Jupyter Notebook
"The Jupyter Notebook is an open-source web application that allows you to create and share documents that contain live code, equations, visualizations and narrative text. Uses include: data cleaning and transformation, numerical simulation, statistical modeling, data visualization, machine learning, and much more."[Jupyter Reference](http://jupyter.org/)

# Enrichments
Another component that sets the HELK apart form other ELK builds is the different enrichments applied to the data it collects.
## AlienVault OTX
"The AlienVault Open Threat Exchange (OTX) is the world’s most authoritative open threat information sharing and analysis network. OTX provides access to a global community of threat researchers and security professionals, with more than 50,000 participants in 140 countries, who contribute over four million threat indicators daily."[AlienVault OTX Reference](https://www.alienvault.com/documentation/otx/about-otx.htm)