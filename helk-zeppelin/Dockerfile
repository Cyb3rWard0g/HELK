# HELK script: HELK Zeppelin Dockerfile
# HELK build version: 0.9 (Alpha)
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause
# Reference: https://github.com/apache/zeppelin/blob/master/scripts/docker/zeppelin/bin/Dockerfile

FROM cyb3rward0g/helk-spark-base:2.3.0
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for the HELK Zeppelin."

ENV DEBIAN_FRONTEND noninteractive

USER root
# *********** Installing Prerequisites ***************
ENV Z_VERSION="0.8."
ENV LOG_TAG="[ZEPPELIN_${Z_VERSION}]:" \
    Z_HOME="/zeppelin"

ENV Z_GID=710
ENV Z_UID=710
ENV Z_USER=zelk

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
RUN echo "$LOG_TAG Install java8" && \
    apt-get -y update && \
    apt-get install -y git openjdk-8-jdk \
    libfontconfig git build-essential chrpath \
    libssl-dev libxft-dev libfreetype6 libfreetype6-dev \
    libfontconfig1 libfontconfig1-dev python3-pip && \
    rm -rf /var/lib/apt/lists/*

# *********** Upgrading PIP ***************
RUN pip3 install --upgrade pip

# *********** Create User *****************
RUN groupadd -r zelk -g ${Z_GID} \
  && useradd -m -s /bin/bash -N -u $Z_UID $Z_USER \
  && chmod g+w /etc/passwd /etc/group \
  && chown -R zelk:zelk /usr/local/ /tmp /usr/bin ${SPARK_HOME}

RUN echo "$LOG_TAG Install python related packages" && \
    apt-get -y update && \
    apt-get install -y gfortran && \
   # numerical/algebra packages
    apt-get install -y libblas-dev libatlas-dev liblapack-dev && \
    # font, image for matplotlib
    apt-get install -y libpng-dev libfreetype6-dev libxft-dev && \
    # for tkinter
    apt-get install -y python-tk libxml2-dev libxslt-dev zlib1g-dev && \
    pip3 install numpy && \
    pip3 install matplotlib

# ************** Install PhantpmJS ****************
USER $Z_UID

# ************** Install Maven *********************
ENV MAVEN_VERSION 3.5.3
RUN wget -qO- http://www.us.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz | tar xvz -C /usr/local && \
    ln -s /usr/local/apache-maven-${MAVEN_VERSION}/bin/mvn /usr/bin/mvn

USER root
# ************** Install Zeppelin *********************
RUN echo "$LOG_TAG Download Zeppelin" && \
    cd /tmp && git clone --branch v0.8.0-rc2 https://github.com/apache/zeppelin.git && \
    mv /tmp/zeppelin ${Z_HOME}

RUN chown -R zelk:zelk ${Z_HOME}

USER $Z_UID

RUN cd $Z_HOME && \
    mvn clean package -DskipTests -X

# *********** Install CAPS ***************
RUN cd ${Z_HOME} && \
    wget https://github.com/opencypher/cypher-for-apache-spark/releases/download/1.0.0-beta7/spark-cypher-1.0.0-beta7-cluster.jar

ADD spark-defaults.conf ${SPARK_HOME}/conf/

USER root
 
RUN echo "$LOG_TAG Cleanup" && \
    apt-get autoclean && \
    apt-get clean

EXPOSE $ZEPPELIN_PORT

WORKDIR ${Z_HOME}
CMD ["bin/zeppelin.sh"]