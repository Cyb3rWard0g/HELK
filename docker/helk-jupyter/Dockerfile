# HELK script: HELK Jupyter Dockerfile
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

FROM cyb3rward0g/helk-spark-base:2.4.0-a
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for HELK Jupyter."

ENV DEBIAN_FRONTEND noninteractive

# *********** Setting Environment Variables ***************
ENV JUPYTER_DIR=/opt/helk/jupyter
ENV ESHADOOP_VERSION=6.5.4
ENV POSTGRESQL_VERSION=42.2.5

# *********** Installing Prerequisites ***************
# -qq : No output except for errors
RUN apt-get update -qq \
  && apt-get install -qqy --no-install-recommends \
  curl python3-pip python3-dev python-tk unzip python3-setuptools \
  libcurl4-openssl-dev build-essential libssl-dev libffi-dev \
  libxml2-dev libxslt1-dev zlib1g-dev postgresql \
  # ********** Install PIP Packages ************
  && sudo pip3 install --upgrade pip \
  && pip3 install pandas==0.24.0 \
  altair==2.3.0 \
  jupyter==1.0.0 \
  jupyterlab==0.35.4 \
  jupyterhub==0.9.4 \
  ipywidgets==7.4.2 \
  # *********** Setting Jupyter Hub & Jupyter **********************
  && curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash - \
  && apt-get install -y --no-install-recommends nodejs \
  && npm install --production -g configurable-http-proxy \
  && jupyter labextension install @jupyterlab/hub-extension@0.12.0 \
  && jupyter labextension install @jupyterlab/celltags@0.1.4 \
  && jupyter labextension install @mflevine/jupyterlab_html@0.1.4 \
  && jupyter labextension install @jupyter-widgets/jupyterlab-manager@0.38.1 \
  && bash -c 'mkdir -pv /opt/helk/{es-hadoop,jupyter,jupyterhub}' \
  && mkdir -v /usr/local/share/jupyter/kernels/pyspark3 \
  && mkdir -v /var/log/spark \
  # *********** Download ES-Hadoop ***************
  && wget https://artifacts.elastic.co/downloads/elasticsearch-hadoop/elasticsearch-hadoop-${ESHADOOP_VERSION}.zip -P /opt/helk/es-hadoop/ \
  && unzip -j /opt/helk/es-hadoop/*.zip -d /opt/helk/es-hadoop/ \
  && rm /opt/helk/es-hadoop/*.zip \
  # ********** Download Postgresql JAR *****************
  && wget https://jdbc.postgresql.org/download/postgresql-${POSTGRESQL_VERSION}.jar -P /opt/helk/spark/jars/ \
  # ********** Clean ******************
  && apt-get -qy clean \
  autoremove \
  && rm -rf /var/lib/apt/lists/*

# *********** Adding HELK scripts and files to Container ***************
COPY scripts/jupyter-entrypoint.sh ${JUPYTER_DIR}
COPY spark/* ${SPARK_HOME}/conf/
COPY kernels/pyspark_kernel.json /usr/local/share/jupyter/kernels/pyspark3/kernel.json
COPY jupyterhub/jupyterhub_config.py ${JUPYTER_DIR}/

# *********** Download Graphframes ***************
#ENV GRAPHFRAMES_VERSION=0.6.0
#RUN wget -qO- https://github.com/graphframes/graphframes/archive/release-${GRAPHFRAMES_VERSION}.tar.gz | sudo tar xvz -C /opt/helk/graphframes/ --strip-components=1 \
#  && mv /opt/helk/graphframes/python/graphframes /opt/helk/spark/python/pyspark/graphframes

EXPOSE 8000
# *********** RUN HELK ***************
WORKDIR ${JUPYTER_DIR}
ENTRYPOINT ["./jupyter-entrypoint.sh"]
CMD ["/bin/bash","-c","/usr/local/bin/jupyterhub","-f","/opt/helk/jupyter/jupyterhub_config.py"]