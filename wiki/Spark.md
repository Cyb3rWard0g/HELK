# Design
[[https://github.com/Cyb3rWard0g/HELK/raw/master/resources/images/SPARK-Design.png]]

# Spark Cluster Standalone Mode
Spark’s standalone cluster manager is a lightweight platform built specifically for Apache Spark workloads. Using it, you can run multiple Spark Applications on the same cluster. It also provides simple interfaces for doing so but can scale to large Spark workloads. The main disadvantage of the standalone mode is that it’s more limited than the other cluster managers— in particular, your cluster can only run Spark.

Chambers, Bill; Zaharia, Matei. Spark: The Definitive Guide: Big Data Processing Made Simple (Kindle Locations 9911-9914). O'Reilly Media. Kindle Edition.

* **Spark Cluster Master:**(often written standalone Master) is the cluster manager for Spark Standalone cluster
* **Spark Cluster Worker:**(aka standalone slave) is a logical node in a Spark Standalone cluster
[Source](https://jaceklaskowski.gitbooks.io/mastering-apache-spark/content/spark-standalone.html)

## Spark Pyspark UI

[[https://github.com/Cyb3rWard0g/HELK/raw/master/resources/images/SPARK-Pyspark-UI.png]]

## Spark Custer Master UI

[[https://github.com/Cyb3rWard0g/HELK/raw/master/resources/images/SPARK-Cluster-Manager.png]]

## Spark Cluster Worker UI

[[https://github.com/Cyb3rWard0g/HELK/raw/master/resources/images/SPARK-Cluster-Worker.png]]

# Jupyter Integration
"The Jupyter Notebook is an open-source web application that allows you to create and share documents that contain live code, equations, visualizations and narrative text. Uses include: data cleaning and transformation, numerical simulation, statistical modeling, data visualization, machine learning, and much more."Jupyter Reference." [Jupyter](http://jupyter.org/)
HELK integrates the Jupyter Notebook project with Spark via the **PYSPARK_DRIVER_PYTHON**. Basically, when the HELK runs **/bin/pyspark**, Jupyter notebook is executed as PYSPARK's Python Driver. The **PYSPARK_DRIVER_PYTHON_OPTS** value is the following:
```
"notebook --NotebookApp.open_browser=False --NotebookApp.ip='*' --NotebookApp.port=8880 --allow-root"
```
# Test Spark, GraphFrames & Jupyter Integration
By default, the Jupyter server gets started automatically after installing the HELK.
* Access the Jupyter Server: 
	* Go to your <HELK's IP>:8880 in your preferred browser
	* Enter the token provided after installing the HELK
* Go to the training/jupyter_notebooks/getting_started/ folder
* Open the Check_Spark_Graphframes_Integrations notebook
	* Check the saved output (Make sure that you have Sysmon & Windows Security event logs being sent to your HELK. Otherwise you will get errors in your Jupyter Notebook when trying to replicate the basic commands)
	* Clear the output from the notebook and run everything again

[[https://github.com/Cyb3rWard0g/HELK/raw/master/resources/images/HELK_checking_integrations.png]]

# Apache Arrow Integration (Convert to Pandas - Optimization)
Apache Arrow is an in-memory columnar data format that is used in Spark to efficiently transfer data between JVM and Python processes. This currently is most beneficial to Python users that work with Pandas/NumPy data. [Apache Spark](https://spark.apache.org/docs/latest/sql-programming-guide.html#pyspark-usage-guide-for-pandas-with-apache-arrow)

[[https://github.com/Cyb3rWard0g/HELK/raw/master/resources/images/SPARK-ApacheArrow.png]]

Example from [Apache Arrow](https://arrow.apache.org/blog/2017/07/26/spark-arrow/)

# Spark Packages
## elasticsearch-hadoop-6.2.4
"Elasticsearch for Apache Hadoop is an open-source, stand-alone, self-contained, small library that allows Hadoop jobs (whether using Map/Reduce or libraries built upon it such as Hive, Pig or Cascading or new upcoming libraries like Apache Spark ) to interact with Elasticsearch. One can think of it as a connector that allows data to flow bi-directionaly so that applications can leverage transparently the Elasticsearch engine capabilities to significantly enrich their capabilities and increase the performance. 
Elasticsearch-hadoop provides native integration between Elasticsearch and Apache Spark, in the form of an RDD (Resilient Distributed Dataset) (or Pair RDD to be precise) that can read data from Elasticsearch. The RDD is offered in two flavors: one for Scala (which returns the data as Tuple2 with Scala collections) and one for Java (which returns the data as Tuple2 containing java.util collections). Just like other libraries, elasticsearch-hadoop needs to be available in Spark’s classpath. As Spark has multiple deployment modes, this can translate to the target classpath, whether it is on only one node (as is the case with the local mode - which will be used through-out the documentation) or per-node depending on the desired infrastructure." [Elastic](https://www.elastic.co/guide/en/elasticsearch/hadoop/current/spark.html)

## graphframes:graphframes:0.5.0-spark2.1-s_2.11
"This is a prototype package for DataFrame-based graphs in Spark. Users can write highly expressive queries by leveraging the DataFrame API, combined with a new API for motif finding. The user also benefits from DataFrame performance optimizations within the Spark SQL engine." [SparkPackages](https://spark-packages.org/package/graphframes/graphframes)
"It aims to provide both the functionality of GraphX and extended functionality taking advantage of Spark DataFrames. This extended functionality includes motif finding, DataFrame-based serialization, and highly expressive graph queries." [Graphframes](https://graphframes.github.io/)

## org.apache.spark:spark-sql-kafka-0-10_2.11:2.3.0
"Structured Streaming integration for Kafka 0.10 to poll data from Kafka" [Structured Streaming Kafka](https://spark.apache.org/docs/latest/structured-streaming-kafka-integration.html)

## databricks:spark-sklearn:0.2.3
"This package contains some tools to integrate the Spark computing framework with the popular scikit-learn machine library. Among other tools: 1) train and evaluate multiple scikit-learn models in parallel. It is a distributed analog to the multicore implementation included by default in scikit-learn. 2) convert Spark's Dataframes seamlessly into numpy ndarrays or sparse matrices. 3) (experimental) distribute Scipy's sparse matrices as a dataset of sparse vectors." [SparkPackages](https://spark-packages.org/package/databricks/spark-sklearn)

# Other Python Packages

## Pandas
"Pandas is an open source, BSD-licensed library providing high-performance, easy-to-use data structures and data analysis tools for the Python programming language." [Pandas Pydata](https://pandas.pydata.org/pandas-docs/stable/overview.html)

## Scipy
"It is a Python-based ecosystem of open-source software for mathematics, science, and engineering." [Scipy Org.](https://www.scipy.org/)

## Scikit-learn
"Simple and efficient tools for data mining and data analysis. Built on NumPy, SciPy, and matplotlib." [Scikit-Learn Org.](http://scikit-learn.org/stable/index.html)

## Nltk
"NLTK is a leading platform for building Python programs to work with human language data. It provides easy-to-use interfaces to over 50 corpora and lexical resources such as WordNet, along with a suite of text processing libraries for classification, tokenization, stemming, tagging, parsing, and semantic reasoning, wrappers for industrial-strength NLP libraries, and an active discussion forum." [Ntlk Org.](http://www.nltk.org/)

## Matplotlib
"Matplotlib is a Python 2D plotting library which produces publication quality figures in a variety of hardcopy formats and interactive environments across platforms. Matplotlib can be used in Python scripts, the Python and IPython shell, the jupyter notebook, web application servers, and four graphical user interface toolkits." [Matplotlib](https://matplotlib.org/index.html)

## Seaborn
"Seaborn is a Python visualization library based on matplotlib. It provides a high-level interface for drawing attractive statistical graphics." [Seaborn Pydata](https://seaborn.pydata.org/index.html)

## Datasketch
"Datasketch gives you probabilistic data structures that can process and search very large amount of data super fast, with little loss of accuracy." [Datasketch Github](https://github.com/ekzhu/datasketch)

## Keras
"Keras is a high-level neural networks API, written in Python and capable of running on top of TensorFlow, CNTK, or Theano. It was developed with a focus on enabling fast experimentation. Being able to go from idea to result with the least possible delay is key to doing good research." [Keras](https://keras.io/)

## Pyflux
"PyFlux is an open source time series library for Python. The library has a good array of modern time series models, as well as a flexible array of inference options (frequentist and Bayesian) that can be applied to these models. By combining breadth of models with breadth of inference, PyFlux allows for a probabilistic approach to time series modelling." [Pyflux Github](https://github.com/RJT1990/pyflux)

## Imbalanced-learn
"imbalanced-learn is a python package offering a number of re-sampling techniques commonly used in datasets showing strong between-class imbalance. It is compatible with scikit-learn and is part of scikit-learn-contrib projects." [Imbalanced Learn](https://github.com/scikit-learn-contrib/imbalanced-learn)

## Lime
"This project is about explaining what machine learning classifiers (or models) are doing. Lime is able to explain any black box classifier, with two or more classes. All we require is that the classifier implements a function that takes in raw text or a numpy array and outputs a probability for each class. Support for scikit-learn classifiers is built-in." [Lime](https://github.com/marcotcr/lime)

## Pyarrow
Apache Arrow is a cross-language development platform for in-memory data. It specifies a standardized language-independent columnar memory format for flat and hierarchical data, organized for efficient analytic operations on modern hardware. It also provides computational libraries and zero-copy streaming messaging and interprocess communication. [Apache Arrow](https://arrow.apache.org/docs/python/)

## NetworkX
NetworkX is a Python package for the creation, manipulation, and study of the structure, dynamics, and functions of complex networks.[NetworkX](https://networkx.github.io/)

## Nxviz
nxviz is a graph visualization package for NetworkX. With nxviz, you can create beautiful graph visualizations by a declarative API. [Nxviz](https://github.com/ericmjl/nxviz)