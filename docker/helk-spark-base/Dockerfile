# HELK script: HELK Spark Base Dockerfile
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

FROM otrf/helk-base:0.0.4
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for HELK Spark."

ENV DEBIAN_FRONTEND noninteractive

# *********** Spark Env Variables ***************
ENV SPARK_VERSION=2.4.4 \
  APACHE_HADOOP_VERSION=2.7 \
  SPARK_HOME=/opt/helk/spark \
  SPARK_LOGS=$SPARK_HOME/logs \
  SPARK_GID=710 \
  SPARK_UID=710 \
  SPARK_USER=sparkuser

# *********** Installing Prerequisites ***************
# -qq : No output except for errors
RUN apt-get update -qq \
  && apt-get install -qqy openjdk-8-jre-headless ca-certificates-java python3 \
  && apt-get -qy clean autoremove \
  && rm -rf /var/lib/apt/lists/* \
  # *********** Installing Spark and creating user ***************
  && bash -c 'mkdir -pv /opt/helk/spark' \
  && wget -qO- https://mirror.reverse.net/pub/apache/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${APACHE_HADOOP_VERSION}.tgz | sudo tar xvz -C /opt/helk/spark --strip-components=1 \
  && mkdir -p $SPARK_LOGS \
  && groupadd -g ${SPARK_GID} ${SPARK_USER} \
  && useradd -u ${SPARK_UID} -g ${SPARK_GID} -d ${SPARK_HOME} --no-create-home ${SPARK_USER} \
  && chown -R ${SPARK_USER}:${SPARK_USER} ${SPARK_HOME}