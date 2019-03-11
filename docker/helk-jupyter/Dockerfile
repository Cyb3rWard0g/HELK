# HELK script: HELK Jupyter Dockerfile
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

FROM cyb3rward0g/helk-spark-base:2.4.0-b
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for HELK Jupyter."

ENV DEBIAN_FRONTEND noninteractive

USER root

# *********** Setting Environment Variables ***************
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV JUPYTER_DIR=/opt/helk/jupyter
ENV CONDA_DIR=/opt/conda
ENV ESHADOOP_VERSION=6.6.1
ENV POSTGRESQL_VERSION=42.2.5
ENV PATH /opt/conda/bin:$PATH
ENV JUSER_GID=810
ENV JUSER_UID=810
ENV JUSER=jupyter
ENV GRAPHFRAMES_VERSION=0.7.0
ENV KAFKA_VERSION=0-10
ENV CONDA_VERSION=4.6.7

# ********** Adding Jupyter User **************
RUN groupadd -g ${JUSER_GID} ${JUSER} \
  && useradd -m -s /bin/bash -u ${JUSER_UID} -g ${JUSER_GID} ${JUSER} \
  && bash -c 'mkdir -pv /opt/helk/{es-hadoop,jupyter/notebooks,jupyterhub}' \
  && chown -R ${JUSER}:${JUSER_GID} /opt ${JUPYTER_DIR} \
  # ********** Installing Initial Requirements ***************
  && apt-get update --fix-missing && apt-get install -y --no-install-recommends \
  wget bzip2 ca-certificates libglib2.0-0 libxext6 libsm6 libxrender1 git mercurial subversion \
  unzip zip postgresql postgresql-contrib \
  && apt-get -qy clean autoremove \
  && rm -rf /var/lib/apt/lists/*

USER $JUSER_UID
# *********** Install Miniconda3 ********************
# **** Current Channels ***********
#- https://repo.anaconda.com/pkgs/main/linux-64
#- https://repo.anaconda.com/pkgs/main/noarch
#- https://repo.anaconda.com/pkgs/free/linux-64
#- https://repo.anaconda.com/pkgs/free/noarch
#- https://repo.anaconda.com/pkgs/r/linux-64
#- https://repo.anaconda.com/pkgs/r/noarch
RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/anaconda.sh \
  && /bin/bash ~/anaconda.sh -b -p /opt/conda \
  && rm ~/anaconda.sh \
  && conda config --system --prepend channels conda-forge \
  && conda install --quiet --yes conda-build \
  # *********** Install Jupyter Notebook & Extra Packages with Conda *************
  && conda install --quiet --yes \
    'python=3.7' \
    'conda=4.6.8' \
    'nbconvert=5.4.1' \
    'notebook=5.7.5' \
    'jupyterhub=0.9.4' \
    'jupyterlab=0.35.4' \
    'pandas=0.24.1' \
    'altair=2.4.1' \
    's3fs=0.2.0' \
    'elasticsearch-dsl=6.3.0' \
    'matplotlib=3.0.3' \
    'scikit-learn=0.20.3' \
  && conda update --all --quiet --yes \
  # *********** Installing Jupyter Extensions *****************
  && jupyter labextension install @jupyterlab/hub-extension@0.12.0 \
  && jupyter labextension install @jupyterlab/celltags@0.1.4 \
  && jupyter labextension install @mflevine/jupyterlab_html@0.1.4 \
  && jupyter labextension install @jupyter-widgets/jupyterlab-manager@0.38.1 \
  && rm -rf $CONDA_DIR/share/jupyter/lab/staging \
  # *********** Clean *****************
  && npm cache clean --force \
  && conda clean -tipy \
  && conda build purge-all \
  && rm -rf /home/$JUSER/.cache/yarn \
  # *********** Install Pip packages not availabe via conda ************
  && python3 -m pip install ksql==0.5.1.1 \
  # *********** Download ES-Hadoop ***************
  && wget https://artifacts.elastic.co/downloads/elasticsearch-hadoop/elasticsearch-hadoop-${ESHADOOP_VERSION}.zip -P /opt/helk/es-hadoop/ \
  && unzip -j /opt/helk/es-hadoop/*.zip -d /opt/helk/es-hadoop/ \
  && rm /opt/helk/es-hadoop/*.zip \
  # ********** Download Postgresql JAR *****************
  && wget https://jdbc.postgresql.org/download/postgresql-${POSTGRESQL_VERSION}.jar -P /opt/helk/spark/jars/ \
  # *********** Download Graphframes Jar ***************
  && wget http://dl.bintray.com/spark-packages/maven/graphframes/graphframes/${GRAPHFRAMES_VERSION}-spark2.4-s_2.11/graphframes-${GRAPHFRAMES_VERSION}-spark2.4-s_2.11.jar -P /opt/helk/spark/jars/ \
  && cp /opt/helk/spark/jars/graphframes* /opt/helk/spark/graphframes.zip \
  # *********** Download Extra Jars ***************
  && wget http://central.maven.org/maven2/org/apache/spark/spark-sql-kafka-${KAFKA_VERSION}_2.11/2.4.0/spark-sql-kafka-${KAFKA_VERSION}_2.11-2.4.0.jar -P /opt/helk/spark/jars/ \
  && wget http://central.maven.org/maven2/org/apache/kafka/kafka-clients/2.1.1/kafka-clients-2.1.1.jar -P /opt/helk/spark/jars/ \
  && wget https://repo1.maven.org/maven2/org/slf4j/slf4j-api/1.7.16/slf4j-api-1.7.16.jar -P /opt/helk/spark/jars/ \
  && wget https://repo1.maven.org/maven2/org/spark-project/spark/unused/1.0.0/unused-1.0.0.jar -P /opt/helk/spark/jars/ \
  && wget https://repo1.maven.org/maven2/org/lz4/lz4-java/1.4.0/lz4-java-1.4.0.jar -P /opt/helk/spark/jars \
  && wget https://repo1.maven.org/maven2/org/xerial/snappy/snappy-java/1.1.7.1/snappy-java-1.1.7.1.jar -P /opt/helk/spark/jars/ \
  && mkdir -v /opt/helk/spark/log

USER root

# *********** Adding HELK scripts and files to Container ***************
COPY --chown=jupyter:810 scripts/* ${JUPYTER_DIR}/
COPY --chown=jupyter:810 spark/* ${SPARK_HOME}/conf/
COPY --chown=jupyter:810 kernels/pyspark_kernel.json /usr/local/share/jupyter/kernels/pyspark3/kernel.json
COPY --chown=jupyter:810 notebooks/* /opt/helk/jupyter/notebooks/

RUN chown jupyter /run/postgresql

EXPOSE 8888 8000
# *********** RUN HELK ***************
WORKDIR ${JUPYTER_DIR}
ENTRYPOINT ["./jupyter-entrypoint.sh"]
CMD ["./jupyter-cmd.sh"]

USER ${JUSER_UID}