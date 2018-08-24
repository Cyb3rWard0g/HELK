# HELK script: HELK Jupyter Dockerfile
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

FROM cyb3rward0g/helk-spark-base:2.3.1-a
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for HELK Jupyter."

ENV DEBIAN_FRONTEND noninteractive

# *********** Installing Prerequisites ***************
# -qq : No output except for errors
RUN echo "[HELK-DOCKER-INSTALLATION-INFO] Updating Ubuntu base image.." \
  && apt-get update -qq
RUN echo "[HELK-DOCKER-INSTALLATION-INFO] Extracting templates from packages.." \
  && apt-get install -qqy --no-install-recommends \
  curl python3-pip python3-dev python-tk unzip python3-setuptools \
  libcurl4-openssl-dev build-essential libssl-dev libffi-dev \
  libxml2-dev libxslt1-dev zlib1g-dev

RUN apt-get -qy clean \
  autoremove

# *********** Upgrading PIP ***************
RUN pip3 install --upgrade pip

# *********** Installing Jupyter Hub Prerequisites
RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
RUN apt-get install -y --no-install-recommends nodejs

# *********** Installing HELK python packages ***************
RUN pip3 install \
  pandas==0.23.4 \
  altair==2.2.2 \
  vega_datasets \
  jupyter==1.0.0 \
  jupyterlab==0.34.1 \
  jupyterhub==0.9.2

# *********** Installing Jupyter Lab Extension - JupyterHub ***************
RUN npm install -g configurable-http-proxy
RUN jupyter labextension install @jupyterlab/hub-extension@0.11.0

# *********** Creating the Jupyter directories ***************
RUN bash -c 'mkdir -pv /opt/helk/{es-hadoop,jupyter,jupyterhub}'
RUN mkdir -v /usr/local/share/jupyter/kernels/pyspark3
RUN mkdir -v /var/log/spark

# *********** Configure Jupyterhub ***************
ENV JUPYTER_DIR=/opt/helk/jupyter

# *********** Adding HELK scripts and files to Container ***************
COPY scripts/jupyter-entrypoint.sh ${JUPYTER_DIR}
COPY notebooks ${JUPYTER_DIR}/notebooks
COPY spark/* ${SPARK_HOME}/conf/
COPY kernels/pyspark_kernel.json /usr/local/share/jupyter/kernels/pyspark3/kernel.json
COPY jupyterhub/jupyterhub_config.py /opt/helk/jupyter/

# *********** Download ES-Hadoop ***************
ENV ESHADOOP_VERSION=6.3.2
RUN wget https://artifacts.elastic.co/downloads/elasticsearch-hadoop/elasticsearch-hadoop-${ESHADOOP_VERSION}.zip -P /opt/helk/es-hadoop/ \
  && unzip -j /opt/helk/es-hadoop/*.zip -d /opt/helk/es-hadoop/ \
  && rm /opt/helk/es-hadoop/*.zip

# *********** Download Graphframes ***************
#ENV GRAPHFRAMES_VERSION=0.6.0
#RUN wget -qO- https://github.com/graphframes/graphframes/archive/release-${GRAPHFRAMES_VERSION}.tar.gz | sudo tar xvz -C /opt/helk/graphframes/ --strip-components=1 \
#  && mv /opt/helk/graphframes/python/graphframes /opt/helk/spark/python/pyspark/graphframes

EXPOSE 8000
# *********** RUN HELK ***************
WORKDIR ${JUPYTER_DIR}
ENTRYPOINT ["./jupyter-entrypoint.sh"]
CMD ["/bin/bash","-c","/usr/local/bin/jupyterhub","-f","/opt/helk/jupyter/jupyterhub_config.py"]