# HELK script: HELK Analytics Dockerfile
# HELK build version: 0.9 (Alpha)
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

FROM phusion/baseimage
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for HELK Analytics."

ENV DEBIAN_FRONTEND noninteractive

# *********** Installing Prerequisites ***************
# -qq : No output except for errors
RUN echo "[HELK-DOCKER-INSTALLATION-INFO] Updating Ubuntu base image.." \
  && apt-get update -qq \
  && echo "[HELK-DOCKER-INSTALLATION-INFO] Extracting templates from packages.." \
  && apt-get install -qqy \
  openjdk-8-jre-headless \
  wget \
  sudo \
  nano \
  python3-pip \
  python-tk \
  unzip \
  zip \
  locales

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen
RUN apt-get -qy clean \
  autoremove \
  && rm -rf /var/lib/apt/lists/*

# *********** Upgrading PIP ***************
RUN pip3 install --upgrade pip

# *********** Installing HELK python packages ***************
RUN pip3 install \
  pandas==0.22.0 \
  jupyter \
  jupyterhub==0.8.1 \
  jupyterlab==0.31.8 \
  https://dist.apache.org/repos/dist/dev/incubator/toree/0.2.0/snapshots/dev1/toree-pip/toree-0.2.0.dev1.tar.gz

RUN pip3 install scipy==1.0.0 \
  scikit-learn==0.19.1 \
  nltk==3.2.5 \
  matplotlib==2.1.2 \
  seaborn==0.8.1 \
  datasketch==1.2.5 \
  keras==2.1.3 \
  pyflux==0.4.15 \
  imbalanced-learn==0.3.2 \
  lime==0.1.1.29 \
  bokeh==0.12.14

# *********** Creating the right directories ***************
RUN bash -c 'mkdir -pv /opt/helk/{scripts,training,es-hadoop,spark,packages}'

# *********** Adding HELK scripts and files to Container ***************
ADD scripts/analytics-entrypoint.sh /opt/helk/scripts/
RUN chmod +x /opt/helk/scripts/analytics-entrypoint.sh
ADD training/ /opt/helk/training/

# *********** Install ES-Hadoop ***************
RUN wget https://artifacts.elastic.co/downloads/elasticsearch-hadoop/elasticsearch-hadoop-6.2.2.zip -P /opt/helk/es-hadoop/ \
  && unzip /opt/helk/es-hadoop/*.zip -d /opt/helk/es-hadoop/ \
  && rm /opt/helk/es-hadoop/*.zip

# *********** Install Spark ***************
ENV SPARK_VERSION=2.3.0
ENV APACHE_HADOOP_VERSION=2.7
ENV ANALYTIC_LOGS_PATH=/var/log/analytics
RUN wget -qO- http://download.nextag.com/apache/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${APACHE_HADOOP_VERSION}.tgz | sudo tar xvz -C /opt/helk/spark/ \
  && mkdir -v $ANALYTIC_LOGS_PATH
ADD spark/.bashrc ~/.bashrc
ADD spark/log4j.properties /opt/helk/spark/spark-${SPARK_VERSION}-bin-hadoop${APACHE_HADOOP_VERSION}/conf/
ADD spark/spark-defaults.conf /opt/helk/spark/spark-${SPARK_VERSION}-bin-hadoop${APACHE_HADOOP_VERSION}/conf/
ADD analytics-init /etc/init.d/analytics

# Adding SPARK environment variables
ENV SPARK_HOME=/opt/helk/spark/spark-${SPARK_VERSION}-bin-hadoop${APACHE_HADOOP_VERSION}
ENV PATH=$SPARK_HOME/bin:$PATH
#ENV SPARK_OPTS="--driver-java-options=-Xms1024M --driver-java-options=-Xmx2096M --driver-java-options=-Dlog4j.logLevel=info --master=local[4]"
ENV SPARK_OPTS="--master local[*]"
ENV PYSPARK_PYTHON=/usr/bin/python3
ENV PYSPARK_DRIVER_PYTHON=/usr/local/bin/jupyter
ENV PYSPARK_DRIVER_PYTHON_OPTS="lab --no-browser --ip=* --port=8880 --allow-root"

# *********** Attaching Toree Kernel to Jupyter ***************
RUN jupyter toree install --spark_home=$SPARK_HOME --interpreters=Scala,SQL

# *********** Update Jupyter PySpark Kernel *************
ADD jupyter/pyspark_kernel.json /usr/local/share/jupyter/kernels/python3/kernel.json

# *********** RUN HELK ***************
EXPOSE 4040 8880

WORKDIR "/opt/helk/scripts/"
ENTRYPOINT ["./analytics-entrypoint.sh"]