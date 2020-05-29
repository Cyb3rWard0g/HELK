# HELK script: HELK Spark Worker Dockerfile
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

FROM otrf/helk-spark-base:2.4.5
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for HELK Spark Worker."

ENV DEBIAN_FRONTEND noninteractive
ENV CONDA_DIR=/opt/conda
ENV PATH=${CONDA_DIR}/bin:$PATH

USER root

RUN chown -R ${SPARK_USER}:${SPARK_USER} /opt

USER ${SPARK_USER}

# https://github.com/ContinuumIO/anaconda-issues/issues/11148
RUN mkdir ${SPARK_HOME}/.conda \
  && cd /tmp \
  && wget --quiet https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/anaconda.sh \
  && /bin/bash ~/anaconda.sh -b -p ${CONDA_DIR} \
  && rm ~/anaconda.sh \
  && conda config --system --prepend channels conda-forge \
  && conda install --quiet --yes conda-build \
  && conda install --quiet --yes \
    'python=3.7.5' \
  && conda update --all --quiet --yes \
  # *********** Clean *****************
  && conda clean -tipcy \
  && conda build purge-all \
  && rm -rf /home/${SPARK_USER}/.cache/yarn

COPY scripts/spark-worker-entrypoint.sh ${SPARK_HOME}/sbin
COPY spark-defaults.conf ${SPARK_HOME}/conf/

WORKDIR $SPARK_HOME/sbin
ENTRYPOINT ["./spark-worker-entrypoint.sh"]