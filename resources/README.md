# Resources

Helpful resources to learn a little bit more about the HELK and its components. They all inspired me to build the HELK!!

# Goals

* Gather as many resources as I can about the components of the HELK to share them with the community all at once.
* Share interesting/valuable resources that helped me and , hopefully, could help others to learn more about ELK, Spark, Kafka, Jupyter, etc.

# Kafka

## Presentations

| Session Title | Description | Speaker |
|--------|---------|-------|
| [ETL Is Dead, Long Live Streams: real-time streams w/ Apache Kafka](https://www.youtube.com/watch?v=I32hmY4diFY) | Neha Narkhede talks about the experience at LinkedIn moving from batch-oriented ETL to real-time streams using Apache Kafka and how the design and implementation of Kafka was driven by this goal of acting as a real-time platform for event data | [@nehanarkhede](https://twitter.com/nehanarkhede) |
| [Building Realtime Data Pipelines with Kafka Connect and Spark Streaming](https://www.youtube.com/watch?v=wMLAlJimPzk&t=698s) | Building Realtime data pipelines with Kafka and Spark | [Ewen Cheslack @confluentinc](https://twitter.com/confluentinc) |

# ElasticStack

## Presentations

| Session Title | Description | Speaker |
|--------|---------|-------|
| [The Quieter You Become, the More You’re Able to (H)ELK](http://www.irongeek.com/i.php?page=videos/bsidescolumbus2018/p05-the-quieter-you-become-the-more-youre-able-to-helk-nate-guagenti-roberto-rodriquez) | This presentation covered the importances of data transformation for your data pipeline. It goes over several challenges and quick affordable solutions to take your elastic stack to the next level. | [@Cyb3rWard0g](https://twitter.com/Cyb3rWard0g) & [@neu5ron](https://twitter.com/neu5ron) |
| [Kibana Custom Graphs with Vega](https://www.youtube.com/watch?v=lQGCipY3th8) | Short demo of how Vega can be used to create interactive Kibana graphs | [@nyuriks](https://twitter.com/nyuriks) |
| [Kibana Scatter Plot Chart via Vega](https://www.youtube.com/watch?v=4xAO01xCBpQ&t=70s) | Tutorial on how to create a scatter plot chart in Kibana using Vega visualization (available since 6.2) or the Vega Kibana plugin by Yuri Astrakhan | Tim Roes |

## Blog Posts

| Name | Description | Author |
|--------|---------|-------|
| [Setting up a Pentesting... I mean, a Threat Hunting Lab - Part 5](https://cyberwardog.blogspot.com/2017/02/setting-up-pentesting-i-mean-threat_98.html) | Installation of an ELK stack. The Debian Way. | [@Cyb3rWard0g](https://twitter.com/Cyb3rWard0g) |
| [Building a Sysmon Dashboard with an ELK Stack](https://cyberwardog.blogspot.com/2017/03/building-sysmon-dashboard-with-elk-stack.html) | Step by step on how to create a basic dashboard with Kibana. | [@Cyb3rWard0g](https://twitter.com/Cyb3rWard0g) |
| [Custom Vega Visualizations in Kibana 6.2](https://www.elastic.co/blog/custom-vega-visualizations-in-kibana) | Step by step on how to create a basic dashboard with Kibana. | [@elastic](https://twitter.com/elastic) |
| [Advanced Sysmon filtering using Logstash](https://www.syspanda.com/index.php/2017/03/03/sysmon-filtering-using-logstash/) | Basic Sysmon configs and Logstash. | [@PabloSyspanda](https://twitter.com/PabloSyspanda) |

## Documentation

| Name | Description | Author |
|--------|---------|-------|
| [Logstash Installation](https://www.elastic.co/guide/en/logstash/current/installing-logstash.html) | Different Ways to install logstash. | [@elastic](https://twitter.com/elastic)|
| [Logstash Input Plugins](https://www.elastic.co/guide/en/logstash/current/input-plugins.html) | An input plugin enables a specific source of events to be read by Logstash. | [@elastic](https://twitter.com/elastic)|
| [Logstash Filter Plugins](https://www.elastic.co/guide/en/logstash/current/filter-plugins.html) | A filter plugin performs intermediary processing on an event. Filters are often applied conditionally depending on the characteristics of the event. | [@elastic](https://twitter.com/elastic)|
| [Logstash Output Plugins](https://www.elastic.co/guide/en/logstash/current/output-plugins.html) | An output plugin sends event data to a particular destination. Outputs are the final stage in the event pipeline. | [@elastic](https://twitter.com/elastic)|
| [Deploying and Scaling Logstash](https://www.elastic.co/guide/en/logstash/current/deploying-and-scaling.html) | The goal of this document is to highlight the most common architecture patterns for Logstash and how to effectively scale as your deployment grows. | [@elastic](https://twitter.com/elastic)|
| [Elasticsearch Installation](https://www.elastic.co/guide/en/elasticsearch/reference/current/install-elasticsearch.html) | Different Ways to install Elasticsearch. | [@elastic](https://twitter.com/elastic)|
| [Elasticsearch Production Deployment](https://www.elastic.co/guide/en/elasticsearch/guide/current/deploy.html) | This chapter is not meant to be an exhaustive guide to running your cluster in production, but it covers the key things to consider before putting your cluster live. | [@elastic](https://twitter.com/elastic)|
| [Kibana Installation](https://www.elastic.co/guide/en/kibana/current/install.html) | Different Ways to install Kibana. | [@elastic](https://twitter.com/elastic)|
| [Kibana Plugins](https://www.elastic.co/guide/en/kibana/current/kibana-plugins.html) | Add-on functionality for Kibana is implemented with plug-in modules. You use the bin/kibana-plugin command to manage these modules. | [@elastic](https://twitter.com/elastic)|
| [Kibana Vega vs VegaLite](https://www.elastic.co/guide/en/kibana/current/vega-vs-vegalite.html) | Details about Vega and VegaLite | [@elastic](https://twitter.com/elastic)|

## others
| Name | type |
|--------|---------|
| [Kibana import/export dashboard api](https://discuss.elastic.co/t/kibana-import-export-dashboard-api/108180) | Elastic Forums|
| [How to pull data data from 2 kafka topics using logstash and index the data in two separate index in elasticsearch](https://discuss.elastic.co/t/how-to-pull-data-data-from-2-kafka-topics-using-logstash-and-index-the-data-in-two-separate-index-in-elasticsearch/114977) | Elastic Forums |

# Spark

## Presentations

| Session Title | Description | Speaker |
|--------|---------|-------|
| [Building Robust ETL Pipelines with Apache Spark](https://www.youtube.com/watch?v=exWGf0aXJF4&t=1181s) | In this talk, we'll take a deep dive into the technical details of how Apache Spark "reads" data and discuss how Spark 2.2's flexible APIs; support for a wide variety of datasources; state of art Tungsten execution engine; and the ability to provide diagnostic feedback to users, making it a robust framework for building end-to-end ETL pipelines | [Xiao Li @databricks](https://twitter.com/databricks) |

## Blog Posts 

| Name | Description | Author |
|--------|---------|-------|
| [Real-Time End-to-End Integration with Apache Kafka in Apache Spark’s Structured Streaming](https://databricks.com/blog/2017/04/04/real-time-end-to-end-integration-with-apache-kafka-in-apache-sparks-structured-streaming.html) | End-to-end integration with Kafka, consuming messages from it, doing simple to complex windowing ETL, and pushing the desired output to various sinks such as memory, console, file, databases, and back to Kafka itself. | [@databricks](https://twitter.com/databricks) |

## Documentation

| Name | Description | Author |
|--------|---------|-------|
| [Spark Overview](https://spark.apache.org/docs/latest/index.html) | Apache Spark Overview. | [@ApacheSpark](https://twitter.com/ApacheSpark)|
| [Spark Standalone Mode](https://spark.apache.org/docs/latest/spark-standalone.html) | Apache Spark Standalone Mode. | [@ApacheSpark](https://twitter.com/ApacheSpark)|
| [Spark SQL, DataFrames and Datasets Guide](https://spark.apache.org/docs/latest/sql-programming-guide.html) | Spark SQL, DataFrames and Datasets Guide. | [@ApacheSpark](https://twitter.com/ApacheSpark)|
| [Spark Python API](https://spark.apache.org/docs/latest/api/python/index.html) | Spark Python API Docs. | [@ApacheSpark](https://twitter.com/ApacheSpark)|
| [Apache Arrow in Spark](https://spark.apache.org/docs/latest/sql-programming-guide.html#pyspark-usage-guide-for-pandas-with-apache-arrow) | Spark Python API Docs. | [@ApacheSpark](https://twitter.com/ApacheSpark)|
| [7 steps for a developer to learn apache spark](https://github.com/Cyb3rWard0g/HELK/blob/master/resources/papers/7-steps-for-a-developer-to-learn-apache-spark.pdf) | 7 steps for a developer to learn apache spark | Databricks |
| [A Gentle Introduction to Apache Spark](https://github.com/Cyb3rWard0g/HELK/blob/master/resources/papers/A-Gentle-Introduction-to-Apache-Spark.pdf) | A Gentle Introduction to Apache Spark | Databricks |
| [Building Continuous Applications with Apache Spark](https://github.com/Cyb3rWard0g/HELK/blob/master/resources/papers/Building-Continuous-Applications-with-Apache-Spark.pdf) | Building Continuous Applications with Apache Spark | Databricks |
| [Data Scientists Guide to Apache-Spark](https://github.com/Cyb3rWard0g/HELK/blob/master/resources/papers/Data-Scientists-Guide-to-Apache-Spark.pdf) | Data Scientists Guide to Apache Spark | Databricks |
| [Getting Started With Apache Spark On Azure Databricks](https://github.com/Cyb3rWard0g/HELK/blob/master/resources/papers/Getting-Started-With-Apache-Spark-On-Azure-Databricks.pdf) | Getting Started With Apache Spark On Azure Databricks | Databricks |
| [Guide to Data Science at Scale](https://github.com/Cyb3rWard0g/HELK/blob/master/resources/papers/Guide-to-Data-Science-at-Scale.pdf) | Guide to Data Science at Scale | Databricks |

## Papers

| Name | Description | Author |
|--------|---------|-------|
| [Spark Cluster Computing with Working Sets](https://github.com/Cyb3rWard0g/HELK/blob/master/resources/papers/Spark_Cluster_Computing_with_Working_Sets.pdf) | Spark Cluster Computing with Working Sets | Matei Zaharia, Mosharaf Chowdhury, Michael J. Franklin, Scott Shenker, Ion Stoica |

# GraphFrames (Spark)

## Presentations

| Session Title | Description | Speaker |
|--------|---------|-------|
| [GraphFrames: Graph Queries In Spark SQL](https://www.youtube.com/watch?v=76LOOORaKBU) | Introduction of GraphFrames. Research focused behind GraphFrames | [@ankurdave](https://twitter.com/ankurdave) |
| [Finding Graph Isomorphisms In GraphX And GraphFrames](https://www.youtube.com/watch?v=B6_dSfPKDXk&t=340s) | Introduction of GraphFrames. Research focused behind GraphFrames | [@michaelmalak](https://twitter.com/michaelmalak) |
| [A Tale of Two Graph Frameworks on Spark: GraphFrames and Tinkerpop](https://www.youtube.com/watch?v=DW09q18OHfc&t=1690s) | Showing two frameworks for doing analytics in graphs with spark as the underline framework for execution | [@__aliv](https://twitter.com/__ali) & [@RussSpitzer](https://twitter.com/RussSpitzer) |
| [GraphFrames: DataFrame-based Graphs for Apache® Spark™](http://go.databricks.com/graphframes-dataframe-based-graphs-for-apache-spark) | developers of the GraphFrames package will give an overview, a live demo, and a discussion of design decisions and future plans. | [@databricks](https://twitter.com/databricks) |
| [Connecting Cassandra Data with GraphFrames](https://www.youtube.com/watch?v=G6myKC47d_c) | We can leverage these roots in a less complicated manner by using GraphFrames and Spark to extract maximum analytical awesomeness from our existing Cassandra data | Jon Haddad |

## Papers

| Name | Description | Author |
|--------|---------|-------|
| [GraphFrames](https://github.com/Cyb3rWard0g/HELK/blob/master/resources/papers/GraphFrames_Introduction.pdf) | An Integrated API for Mixing Graph and Relational Queries | Ankur Dave, Alekh Jindal, Li Erran Li, Reynold Xin, Joseph Gonzalez, Matei Zaharia |