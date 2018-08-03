# HELK script: HELK Zeppelin Dockerfile
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0
# Reference: 
# https://github.com/apache/zeppelin/blob/master/scripts/docker/zeppelin/bin/Dockerfile
# https://hub.docker.com/r/apache/zeppelin/~/dockerfile/

FROM cyb3rward0g/helk-spark-base:2.3.1
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for the HELK Zeppelin."

ENV DEBIAN_FRONTEND noninteractive

USER root
# *********** Installing Prerequisites ***************
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
RUN apt-get -y update && \
    apt-get install -y git openjdk-8-jdk \
    libfontconfig git build-essential chrpath \
    libssl-dev libxft-dev libfreetype6 libfreetype6-dev \
    libfontconfig1 libfontconfig1-dev python3-pip && \
    rm -rf /var/lib/apt/lists/*

# *********** Upgrading PIP ***************
RUN pip3 install --upgrade pip

RUN apt-get -y update && \
    apt-get install -y gfortran && \
   # numerical/algebra packages
    apt-get install -y libblas-dev libatlas-dev liblapack-dev && \
    # font, image for matplotlib
    apt-get install -y libpng-dev libfreetype6-dev libxft-dev && \
    # for tkinter
    apt-get install -y python-tk libxml2-dev libxslt-dev zlib1g-dev && \
    pip3 install numpy && \
    pip3 install matplotlib

# *********** Creating the right directories ***************
RUN bash -c 'mkdir -pv /opt/helk/{es-hadoop,zeppelin}'

# ************** Install Zeppelin *********************
ENV Z_VERSION=0.8.0
ENV SPARK_CYPHER_VERSION=0.1.6
ENV Z_HOME="/opt/helk/zeppelin"
ENV ZEPPELIN_PORT=9090

RUN wget -qO- http://archive.apache.org/dist/zeppelin/zeppelin-${Z_VERSION}/zeppelin-${Z_VERSION}-bin-all.tgz | sudo tar xvz -C ${Z_HOME} --strip-components=1

# *********** Install CAPS ***************
RUN wget https://github.com/opencypher/cypher-for-apache-spark/releases/download/${SPARK_CYPHER_VERSION}/spark-cypher-${SPARK_CYPHER_VERSION}-cluster.jar -P ${Z_HOME}

# *********** Download ES-Hadoop ***************
ENV ESHADOOP_VERSION=6.3.1
RUN wget https://artifacts.elastic.co/downloads/elasticsearch-hadoop/elasticsearch-hadoop-${ESHADOOP_VERSION}.zip -P /opt/helk/es-hadoop/ \
  && unzip -j /opt/helk/es-hadoop/*.zip -d /opt/helk/es-hadoop/ \
  && rm /opt/helk/es-hadoop/*.zip

# *********** Add Spark User rights to Zeppelin Folder ***************
RUN chown -R ${SPARK_USER}:${SPARK_USER} ${Z_HOME} /opt/helk/es-hadoop

USER $SPARK_UID

# *********** Add Custom SPark Conf ******
ADD spark-defaults.conf ${SPARK_HOME}/conf/

EXPOSE 9090

WORKDIR ${Z_HOME}
CMD ["bin/zeppelin.sh"]