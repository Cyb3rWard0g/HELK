# HELK script: HELK Jupyter Dockerfile
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

FROM cyb3rward0g/helk-spark-base:2.3.1
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for HELK Jupyter."

ENV DEBIAN_FRONTEND noninteractive

USER root

# *********** Installing Prerequisites ***************
# -qq : No output except for errors
RUN echo "[HELK-DOCKER-INSTALLATION-INFO] Extracting templates from packages.." \
  && apt-get install -qqy \
  python3-pip \
  python-tk \
  unzip

RUN apt-get -qy clean \
  autoremove

# *********** Upgrading PIP ***************
RUN pip3 install --upgrade pip

# *********** Installing Jupyter Hub Prerequisites
RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
RUN apt-get install -y nodejs

# *********** Installing HELK python packages ***************
RUN pip3 install pandas \
  jupyter \
  jupyterlab \
  jupyterhub

RUN npm install -g configurable-http-proxy
RUN jupyter labextension install @jupyterlab/hub-extension

# *********** Creating the right directories ***************
RUN bash -c 'mkdir -pv /opt/helk/{es-hadoop,jupyter}'

# *********** Setting Jupyterhub***********************
ENV JUPYTER_DIR=/opt/helk/jupyter

# *********** Adding HELK scripts and files to Container ***************
ADD scripts/jupyter-entrypoint.sh ${JUPYTER_DIR}
ADD notebooks ${JUPYTER_DIR}/notebooks

# *********** Download ES-Hadoop ***************
ENV ESHADOOP_VERSION=6.3.1
RUN wget https://artifacts.elastic.co/downloads/elasticsearch-hadoop/elasticsearch-hadoop-${ESHADOOP_VERSION}.zip -P /opt/helk/es-hadoop/ \
  && unzip -j /opt/helk/es-hadoop/*.zip -d /opt/helk/es-hadoop/ \
  && rm /opt/helk/es-hadoop/*.zip

# *********** Configure Jupyterhub ***************
ENV JUPYTER_LOGS_PATH=${JUPYTER_DIR}/log
ENV JUPYTER_CONSOLE_LOG=${JUPYTER_LOGS_PATH}/jupyter.log
ENV JUPYTER_EXEC=$SPARK_HOME/bin/pyspark
ENV JUPYTER_LOGS=">> $JUPYTER_CONSOLE_LOG 2>&1"

RUN mkdir -v $JUPYTER_LOGS_PATH
ADD spark/log4j.properties ${SPARK_HOME}/conf/
ADD spark/spark-defaults.conf ${SPARK_HOME}/conf/

# *********** Update Jupyter PySpark Kernel *************
#ADD kernels/pyspark_kernel.json /usr/local/share/jupyter/kernels/python3/kernel.json

# ************* Adding SPARK environment variables *************
ENV PATH=$SPARK_HOME/bin:$PATH
ENV PYSPARK_PYTHON=/usr/bin/python3
ENV PYSPARK_DRIVER_PYTHON=/usr/local/bin/jupyter
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip
ENV PYSPARK_DRIVER_PYTHON_OPTS="lab --no-browser --ip=* --port=8880 --allow-root --notebook-dir=/opt/helk/jupyter/notebooks"

EXPOSE 4040 8880

# *********** RUN HELK ***************
WORKDIR ${JUPYTER_DIR}
ENTRYPOINT ["./jupyter-entrypoint.sh"]