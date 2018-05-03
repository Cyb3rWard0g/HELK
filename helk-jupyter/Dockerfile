# HELK script: HELK Jupyter Dockerfile
# HELK build version: 0.9 (Alpha)
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

FROM cyb3rward0g/helk-spark-base:2.3.0
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for HELK Jupyter."

ENV DEBIAN_FRONTEND noninteractive

# *********** Installing Prerequisites ***************
# -qq : No output except for errors
RUN echo "[HELK-DOCKER-INSTALLATION-INFO] Updating Ubuntu base image.." \
  && apt-get update -qq \
  && echo "[HELK-DOCKER-INSTALLATION-INFO] Extracting templates from packages.." \
  && apt-get install -qqy \
  python3-pip \
  python-tk \
  unzip

RUN apt-get -qy clean \
  autoremove

# *********** Upgrading PIP ***************
RUN pip3 install --upgrade pip

# *********** Installing HELK python packages ***************
RUN pip3 install pandas \
  jupyter \
  jupyterlab

RUN pip3 install scipy \
  scikit-learn \
  nltk \
  enum34 \
  matplotlib==2.1.2 \
  seaborn \
  datasketch \
  keras \
  pyflux \
  imbalanced-learn \
  lime \
  bokeh \
  networkx==2.0 \
  numpy==1.14.0 \
  nxviz \
  hiveplot \
  pyarrow

# *********** Creating the right directories ***************
RUN bash -c 'mkdir -pv /opt/helk/{notebooks,es-hadoop}'

# *********** Adding HELK scripts and files to Container ***************
ADD scripts/jupyter-entrypoint.sh /opt/helk/
RUN chmod +x /opt/helk/jupyter-entrypoint.sh
ADD notebooks/ /opt/helk/notebooks/

# *********** Install ES-Hadoop ***************
ENV ESHADOOP_VERSION=6.2.4
RUN wget https://artifacts.elastic.co/downloads/elasticsearch-hadoop/elasticsearch-hadoop-${ESHADOOP_VERSION}.zip -P /opt/helk/es-hadoop/ \
  && unzip /opt/helk/es-hadoop/*.zip -d /opt/helk/es-hadoop/ \
  && rm /opt/helk/es-hadoop/*.zip

# *********** Configure Spark ***************
ENV JUPYTER_LOGS_PATH=/var/log/jupyter
ENV JUPYTER_CONSOLE_LOG=/var/log/jupyter/jupyter.log
ENV JUPYTER_EXEC=$SPARK_HOME/bin/pyspark
ENV JUPYTER_LOGS=">> $JUPYTER_CONSOLE_LOG 2>&1"

RUN mkdir -v $JUPYTER_LOGS_PATH
ADD spark/log4j.properties ${SPARK_HOME}/conf/
ADD spark/spark-defaults.conf ${SPARK_HOME}/conf/

# ************* Adding SPARK environment variables *************
ENV PATH=$SPARK_HOME/bin:$PATH
ENV PYSPARK_PYTHON=/usr/bin/python3
ENV PYSPARK_DRIVER_PYTHON=/usr/local/bin/jupyter
ENV PYSPARK_DRIVER_PYTHON_OPTS="lab --no-browser --ip=* --port=8880 --allow-root"

# *********** Update Jupyter PySpark Kernel *************
ADD kernels/pyspark_kernel.json /usr/local/share/jupyter/kernels/python3/kernel.json

# *********** RUN HELK ***************
EXPOSE 4040 8880

WORKDIR "/opt/helk/"
ENTRYPOINT ["./jupyter-entrypoint.sh"]