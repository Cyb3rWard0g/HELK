# HELK script: HELK Jupyter Dockerfile
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

FROM cyb3rward0g/jupyter-hunter:0.0.9
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile Notebooks-Forge Jupyter-Hunt Project."

ENV DEBIAN_FRONTEND noninteractive

USER root

# *********** Setting Environment Variables ***************
ENV POSTGRESQL_VERSION=42.2.9

# ********** Installing additional libraries **************
RUN mkdir /opt/jupyter/notebooks/datasets \
    && apt-get update --fix-missing && apt-get install -y --no-install-recommends \
    postgresql postgresql-contrib \
    # ********** Clean APT **********
    && apt-get -qy clean autoremove \
    && rm -rf /var/lib/apt/lists/* \
    # ********** Download Postgresql JAR *****************
    && wget https://jdbc.postgresql.org/download/postgresql-${POSTGRESQL_VERSION}.jar -P /opt/jupyter/spark/jars/

# *********** Adding HELK scripts and files to Container ***************
COPY notebooks/demos ${JUPYTER_DIR}/notebooks/demos
COPY notebooks/tutorials ${JUPYTER_DIR}/notebooks/tutorials
COPY notebooks/sigma ${JUPYTER_DIR}/notebooks/sigma
COPY spark/* ${SPARK_HOME}/conf/
COPY scripts/* ${JUPYTER_DIR}/scripts/

RUN chown -R ${USER} ${JUPYTER_DIR} ${HOME} ${SPARK_HOME} \
    && chown ${USER} /run/postgresql

WORKDIR ${HOME}
ENTRYPOINT ["/opt/jupyter/scripts/jupyter-entrypoint.sh"]
CMD ["/opt/jupyter/scripts/jupyter-cmd.sh"]

USER ${USER}

