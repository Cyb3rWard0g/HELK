# HELK script: HELK Jupyter Dockerfile
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

FROM cyb3rward0g/jupyter-hunt:0.0.2
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile Notebooks-Forge Jupyter-Hunt Project."

USER root
# ********** Adding HELK Jupyter notebooks
RUN mkdir /opt/helk/jupyter/notebooks/datasets
COPY notebooks/* /opt/helk/jupyter/notebooks/
COPY datasets/* /opt/helk/jupyter/notebooks/datasets/
RUN chown -R ${USER} /opt/helk/jupyter/notebooks/

USER ${USER}

